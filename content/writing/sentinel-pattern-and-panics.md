+++
title = "(Un)safely moving elements out of borrowed data"
description = "Editing contiguous data collections"
date = 2025-11-19

[extra]
toc = false
draft = true

[taxonomies]
tags = ["rust"]
+++

## Temporarily moving elements out of collections
A recurring pattern when working with collections is the following.
Suppose I have a collection, like a `Vec<T>`, and suppose I would like to take an element out and replace it with a new one.

Fortunately for us, holding a mutable reference is almost the same as having ownership, so we can for example use [`replace`](https://doc.rust-lang.org/std/mem/fn.replace.html):
```rust
fn replace_at_index<T>(vec: &mut Vec<T>, idx: usize, new: T) -> T {
    std::mem::replace(&mut vec[idx], new)
}
```
What happens if we want the replacement element to depend on the element that we just removed?
```rust
fn replace_with<T, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(T) -> T,
{
    let e = vec.remove(idx);
    vec.insert(idx, f(e))
}
```
This solution is very inefficient!
`vec.remove` removes the element at `idx`, and then *shifts all of the remaining elements left*, which we then proceed to *immediately shift back*.
This happens since a `Vec` must always be contiguous in memory.

If we can get away with it, we could pass an `&mut T` reference in the closure, instead of passing ownership.
```rust
fn update_with<T, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(&mut T),
{
    f(&mut vec[idx]);
}
```
For example, this is the approach that the [entry API](https://doc.rust-lang.org/std/collections/hash_map/enum.Entry.html) takes.
However, this still requires having the new element at hand at the point when it is replaced; we've just deferred the call to `replace` farther into the closure.

For a more realistic{% inline_note() %}At least this is the example that motivated me to think about this problem.{% end %} situation analogous to the above, suppose we in fact want to replace the element at `idx` with an iterator of elements which can depend on the index.
Here, the analogy to `insert` is [`splice`](https://doc.rust-lang.org/std/vec/struct.Vec.html#method.splice):
```rust
fn update_with_iter<T, F, I>(vec: &mut Vec<T>, idx: usize, f: F)
where
    I: IntoIterator<Item = T>,
    F: FnOnce(T) -> I,
{
    // the same inefficient solution
    let new = vec.remove(idx);
    vec.splice(idx..idx, f(new))
}
```
Our goal is to optimize this implementation to avoid shifting the elements twice, and ideally (for example, if the iterator contains exactly one element) to not shift the elements at all.

### Why do we have to be careful?
Let's do something illegal.
```rust
fn replace_with<T, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(T) -> T,
{
    assert!(idx < vec.len());
    // please don't do this
    unsafe {
        // the location of the element
        let p = vec.as_mut_ptr().add(idx);

        let e = std::ptr::read(p);
        let new = f(e);

        // write the new element without reading or dropping the original value
        std::ptr::write(p, new);
    };
}
```
The short answer is: what happens if the closure panics?

If the closure `f` panics here, the element `T` could be freed twice: first by the closure itself (which took ownership of `T`), and then by the `Drop` implementation of `Vec`, which cleans up its own memory.
The crux of the issue is that a `Vec` assumes that all of its elements are *always* in an initialized state.

### A safe solution: using a sentinel value
A safe pattern is to use a cheap default value to swap with the element.
The idea is the following: first, swap the default value for the element, then do something with the element, and then swap back.

For example, if `T::default()` is cheap (for instance if `T` is an `Option<U>`):
```rust
use std::mem::swap;

fn replace_with<T: Default, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(T) -> T,
{
    let mut sentinel = T::default();

    swap(&mut sentinel, &mut vec[idx]);
    let mut new = f(sentinel);
    swap(&mut new, &mut vec[idx]);
}
```
Now if `f` panics, the original vector could be left in a logically invalid state, but this will not result in memory corruption.

What happens if `T` does not have a cheap default?
We can just use other values already in the `Vec`!
```rust
fn replace_with<T, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(T) -> T,
{
    let x = vec.swap_remove(idx);
    let last_idx = vec.len();
    vec.push(f(x));
    vec.swap(idx, last_idx);
}
```
Finally, for the `replace_iter` variant, this is the analogous implementation:
```rust
pub fn replace_iter<F, T, I>(vec: &mut Vec<T>, idx: usize, f: F)
where
    I: IntoIterator<Item = T>,
    F: FnOnce(T) -> I,
{
    if idx + 1 == vec.len() {
        let e = vec.pop().unwrap();
        vec.extend(f(e));
    } else {
        // swap with the last element
        let e = vec.swap_remove(idx);

        // splice in the new elements into the position
        // occupied by the last element
        let last = {
            let mut iter = vec.splice(idx..idx + 1, f(e));
            iter.next().unwrap()
        };

        // put the last element back
        vec.push(last);
    }
}
```
The idea that the data could be left in an invalid state is particularly important in multi-threaded code.
If we access the vector through a [mutex](https://doc.rust-lang.org/std/sync/struct.Mutex.html), and then our closure panics while calling one of the above `replace_with` functions, the fact that the data is invalid could result in logic errors in the other thread.
This is referred to as [poisoning](https://doc.rust-lang.org/std/sync/struct.Mutex.html#poisoning).

If you are still interested in the sentinel pattern, Niko Matsakis has a [nice article](https://smallcultfollowing.com/babysteps/blog/2018/11/10/after-nll-moving-from-borrowed-data-and-the-sentinel-pattern/) about it.


## Solutions using unsafe code
Now let's revisit our earlier problems and solve them using unsafe Rust.

### Updating an element in-place with a closure
Let's start with `replace_with`.
Let's recalling our issue from before.
If the closure panics, the element which we are replacing could be freed twice: once by the closure itself while unwinding, and again by the `Vec`.

A common way to work around this issue is to tell the vector that it is no longer responsible for the memory.
```rust
fn replace_with<T, F>(vec: &mut Vec<T>, idx: usize, f: F)
where
    F: FnOnce(T) -> T,
{
    assert!(idx < vec.len());
    unsafe {
        let original_len = vec.len();

        // now the vector is only responsible for elements 0..idx
        vec.set_len(idx);

        // update the element
        let p = vec.as_mut_ptr().add(idx);
        let e = std::ptr::read(p);
        let new = f(e);
        std::ptr::write(p, new);

        // this is valid since the element at `idx` is once again initialized
        vec.set_len(original_len);

    };
}
```
Now, if `f` panics, `e` is dropped by the closure, and the elements in the vector preceding `e` are dropped by the `Vec`.

In case of a panic, the elements which follow `e` will be leaked.
This does not cause undefined behaviour; generally speaking leaking is a [safe operation](https://doc.rust-lang.org/std/mem/fn.forget.html).
However, leaking memory isn't great if we can avoid it.

### Replacing an element with an iterator
Now let's handle the general case in `replace_iter`.

In order to minimize the amount of unsafe code we have to write, and also to depend on the optimized implementation of `splice` in the standard library, we can take the following approach:

1. Start with the approach from `replace_with`: temporarily set the length, use `ptr::read` to load the element we want to replace, and then apply the closure to get the new iterator.
2. If the iterator is empty, shift the remaining elements back by 1 index, correct the length, and return. Otherwise, it has at least one element, so we can use `ptr::write` to put that element back.
3. At this point, the vector is back in an initialized state, so we can use `splice` to insert the remaining elements at the next index.

This looks like the following in practice:
```rust
pub fn replace_iter<F, T, I>(vec: &mut Vec<T>, idx: usize, f: F)
where
    I: IntoIterator<Item = T>,
    F: FnOnce(T) -> I,
{
    assert!(idx < vec.len(), "index out of bounds");

    unsafe {
        let original_len = vec.len();

        // the place we are removing from
        let ptr = vec.as_mut_ptr().add(idx);
        let item = std::ptr::read(ptr);

        // temporarily decrease length to avoid double-free if the
        // closure or some iterator method panics
        vec.set_len(idx);

        // get the replacement iterator
        let mut iter = f(item).into_iter();

        match iter.next() {
            None => {
                // empty iterator - shift everything down to fill in the original spot
                std::ptr::copy(ptr.add(1), ptr, original_len - idx - 1);
                vec.set_len(original_len - 1);
            }
            Some(first) => {
                // put the element back
                std::ptr::write(ptr, first);

                // the vec is once again in an initialized state so we can reset the length
                vec.set_len(original_len);

                // splice in the remaining elements
                let _ = vec.splice(idx + 1..idx + 1, iter);
            }
        }
    }
}
```

+++
title = "Using Closure-style Traits to Simplify a Rust API"
description = "Some thoughts on API design with GATs from implementing a generic picker library"
date = 2024-12-04

[extra]
toc = true

[taxonomies]
tags = ["rust", "cli"]
+++

## Introduction
I recently published a [Rust](https://www.rust-lang.org/) library called [`nucleo-picker`](https://docs.rs/nucleo-picker/latest/nucleo_picker) which enables command-line applications to incorporate an interface for making a selection from a number of provided options.
The selection is done through an interactive query, with a search algorithm used to filter and rank the given possibilities.
A popular choice, and the one internal to `nucleo-picker`{% inline_note() %}Not my implementation, but rather from Pascal Kuthe's [`nucleo`](https://docs.rs/nucleo/latest/nucleo) crate.{% end %}, is to use the [Smith–Waterman algorithm](https://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm) from DNA sequence alignment since it is relatively simple to implement, performant even in the presence of a large number of matches, and not too sensitive to typos and other user input errors.

In our case, since we are implementing a library, we do not make any choices concerning rendering: instead, the library user must define how their types should be represented within the picker.
In the end, I decided on the following closure-style trait with generic associated types.
```rust
pub trait Render<T> {
    type Str<'a>: AsRef<str>
    where
        T: 'a;

    fn render<'a>(&self, item: &'a T) -> Self::Str<'a>;
}
```
I would like to discuss my thought process behind this choice, and mainly why this API differs from the much more popular [skim](https://docs.rs/skim/latest/skim) picker library.
Instead of just explaining the benefits of such a choice, let's work our way through some alternative approaches and see how this solution arises.

## No generics
The first possibility, and certainly the simplest possible choice, is simply to have a concrete type within the picker that the item must be rendered as.
For instance, one might require that all items are sent to the picker as a `String`, or some other internal representation.
Internally, for performance reasons, this can be quite ideal: since a matcher engine must perform a large number of score computations every time the query string changes, having an optimized internal representation can greatly improve performance.

However, there are quite a few issues with this approach.

### Overhead to keep track of items
The first issue is that the user needs to keep track of the items by themselves.
There can be quite a bit of implementation overhead to doing this, especially if for performance you want multi-threading: the user must maintain an internal global item queue (such as an [append-only vector](https://crates.io/crates/boxcar)) and track the association between the items and the rendered format.
This is something we would like to deal with on behalf of the user.

### Conversion overhead and API commitment
If you have a custom internal type which requires pre-processing to generate (such as a `Vec<char>`), the user must convert to your provided type.
You can provide adapters for your type, such as `From<String>`; however, the user must still import your type, understand the subtleties, and track down the relevant adapter.
Moreover, this is an additional API commitment if your internal representation changes, since you must continue to support the previous conversion methods.

### Extra memory overhead with lossy representation
In many situations, internally one does not actually want to store the rendered value, but rather a representation which is optimized for matching.
For example, it is often quite ideal to begin with a string slice, iterate over [graphemes](https://unicode.org/reports/tr29/), and then [normalize the grapheme](https://unicode.org/reports/tr15/) to avoid issues with non-canonical representation.
In particular, it may be insufficient to only store the internal representation, and the picker may require two representations: the first, which is a user-friendly rendered format (such as `String`), and the second, which is an internal representation only used for matching.
This unnecessarily incurs additional memory overhead.


## A trait for picker items
We've now decided that we want to keep track of the items on behalf of the user and maintain our own internal representation, so the picker is now generic over an item type `T`.
In order for the user to explain how to render the item `T`, perhaps the first solution that many people will reach for is to require that `T` implements a trait such as
```rust
trait Item {
    fn text(&self) -> Cow<'_, str>;
}
```
This is the approach taken by [skim](https://docs.rs/skim/latest/skim/trait.SkimItem.html).
Then, the picker is generic over any type `T` which implements `Item`, and then uses the `Item` implementation to generate the internal representation, and also to represent the item within the picker view (if the internal representation is lossy).

### Implementation on foreign types
The first concern, which is more of an inconvenience rather than a serious problem, is that an `Item` trait increases the number of wrapper types if a user wants to have a picker item which is not local to the crate.
This is a relatively common concern for the picker: for example, if you wanted to implement a `find` clone with a picker interface on the matching items, you might import the [ignore](https://docs.rs/ignore/latest/ignore/) crate, and then the natural choice for an item is a `DirEntry`.


### Difficulty in default implementation
In order to alleviate the user responsibility, one could in principle preemptively implement `Item` for as many foreign types as possible.
For instance (and again, this is done by [skim](https://docs.rs/skim/latest/skim/trait.SkimItem.html)), one might have an implementation such as
```rust
impl<T: AsRef<str>> Item for T {
    fn text(&self) -> Cow<'_, str> {
        Cow::Borrowed(self.as_ref())
    }
}
```
A downside of this approach is that it will result in conflicting implementations if the user's type already implements `AsRef<str>` but they wish for the rendered value to be different than the default `str` implementation.

Moreover, to avoid conflicting implementations, one cannot have a second implementation, such as
```rust
impl<P: AsRef<Path>> Item for P {
    fn text(&self) -> Cow<'_, str> {
        self.as_ref().to_string_lossy()
    }
}
```
since in principle a type could be `AsRef<str> + AsRef<Path>`; for example, this is the case for `String`.
Therefore, one must make such a choice concerning the generic implementation, which may be inconvenient for a downstream user who would benefit from a different default implementation.

Again using newtypes, it is possible to work around this problem: we could implement a custom wrapper type `PathItem` and implement `Item` for it:
```rust
struct PathItem<P> {
    inner: P
}

impl<P: AsRef<Path>> PathItem<P> {
    fn new(inner: P) -> Self {
        Self { inner }
    }
}

impl<P: AsRef<Path>> Item for PathItem<P> {
    fn text(&self) -> Cow<'_, str> {
        self.inner.as_ref().to_string_lossy()
    }
}
```
But then the user must wrap their internal type `P` with `PathItem` before passing it to the `Picker`, and then unwrap the item when it is returned.


### Inflexibility with stateful rendering patterns
The final concern, which is more serious, is that a library user may want rendering to also depend on additional dynamic state.
For example, the picker item might be a `HashMap`, and the library user might wish to only render a subset of the keys, but still retain all of the `HashMap` data when the item is picked.
Implementing this with an `Item` then requires modifying the item type `T` to contain the required rendering state, which could either result in substantial overhead or lifetime headaches.

In the `HashMap` example, one would have to do something like
```rust
struct SubsetHashMap {
    map: BTreeMap<String, String>,
    allowed_fields: Arc<HashSet<String>>,
}

impl Item for SubsetHashMap {
    fn text(&self) -> Cow<'_, str> {
        Cow::Owned(self.map
            .iter()
            .filter(|(k, _)| self.allowed_fields.contains(k.as_str()))
            .map(|(_, v)| v)
            .join(", ")
            .into())
    }
}
```
but now we have the extra (unnecessary) reference counting overhead, along with a rather in-elegant `SubsetHashMap`.

## A closure for rendering
After understanding the issues with the `Item` trait, it seems that we should take a different perspective on the implementation: instead of asking for the item `T` to describe how it should be rendered, we should instead ask the user to specify a *second* type `R` which knows how to render `T`.
In other words, `R` is a *rendering function*, so a natural choice for such a type is a *closure*.
In our case, the natural trait bound is something like
```rust
for<'a> Fn(&'a T) -> Cow<'a, str>;
```
Now, we ask the library user to pass a rendering function directly to the picker when it is instantiated, rather than define rendering per-item.
```rust
struct Picker<T, R> {
    renderer: R,
    _marker: PhantomData<T>, // just a placeholder to make this example compile
}

impl<T, R> Picker<T, R>
where
    R: for<'a> Fn(&'a T) -> Cow<'a, str>,
{
    fn render<'a>(&self, item: &'a T) -> Cow<'a, str> {
        // now we can internally render items for display
        (self.renderer)(item)
    }
}
```
This is quite close to an optimal solution and it addresses the key issues above.

1. Implementation on foreign types requires minimal boilerplate, since we just need to write the appropriate function.
2. The closure itself can own the relevant state by using `move`.
3. There is minimal memory overhead, since all of the required state is held inside the closure, which is only instantiated once.

This implementation basically de-sugars to our original `Render` trait with the concrete `Cow<'a, str>` return type.
However, there is still one key issue with ergonomics that we would like to overcome.

### Inflexible return type
In the above examples, we mandated a `Cow<'_, str>` return type, which is generally speaking quite sensible.
However, we might wish to allow the user even more flexibility and decide what the return type should be, as long as we can extract the desired data from it.
For instance, we would like the closure to be able to return any type which is `AsRef<str>`.
Let's try to implement this by doing something a bit silly.
```rust
struct Picker<T, R> {
    renderer: R,
    _marker: PhantomData<T>,
}

impl<T, R, S> Picker<T, R>
where
    S: AsRef<str>,
    R: for<'a> Fn(&'a T) -> S,
{
    fn render<'a>(&self, item: &'a T) -> S {
        // now we can internally render items for display
        (self.renderer)(item)
    }
}
```
Well, let's try it out:
```rust
Picker::new(|s: &String| AsRef::<str>::as_ref(s));
```
Unfortunately, that doesn't work:
```text
error: lifetime may not live long enough
  --> src/lib.rs:59:31
   |
59 |     Picker::new(|s: &String| AsRef::<str>::as_ref(s));
   |                     -      - ^^^^^^^^^^^^^^^^^^^^^^^ returning this value requires that `'1` must outlive `'2`
   |                     |      |
   |                     |      return type of closure is &'2 str
   |                     let's call the lifetime of this reference `'1`
```
The problem is that the type signature of the closure `R` should also specify `S` outlives `'a`, but since `'a` is a parameter which is only local to `R`, we cannot capture it in the generic return type of `R`.

In fact, this (invalid) type signature has a more fundamental issue: the type parameter `S` should not be constrained by `R`, but rather should be an [associated type](https://doc.rust-lang.org/reference/items/associated-items.html#associated-types).
Just like the `for <'a>` lifetime bound, the type parameter `S` should only be visible within the renderer and we should not be bounding at the Picker implementation level.
This is quite natural, since the return type of the closure should be decided by the specific implementation of the closure itself!

Unfortunately, generic return types are currently{% inline_note() %}Well, at least as far as I am aware, and in Rust 1.82.{% end %} not supported in closures.
The solution is to use a trait which imitates such a closure.

## The solution: closure-style trait with generic associated types
First, let's desugar the original closure type as an explicit trait:
```rust
trait Render<T> {
    fn render<'a>(&self, item: &'a T) -> Cow<'a, str>;
}
```
And then let's add a [generic associated type](https://blog.rust-lang.org/2022/10/28/gats-stabilization.html) to allow the user to decide on a return value which may optionally borrow from the item itself.
```rust
pub trait Render<T> {
    type Str<'a>: AsRef<str>
    where
        T: 'a;

    fn render<'a>(&self, item: &'a T) -> Self::Str<'a>;
}
```
The `where T: 'a` is a [non-local requirement](https://blog.rust-lang.org/2022/10/28/gats-stabilization.html#non-local-requirements-for-where-clauses-on-gats) since this bound is implied by the signature of render.

Finally, we have the corresponding picker implementation:
```rust
struct Picker<T, R> {
    renderer: R,
    _marker: PhantomData<T>,
}

impl<T, R: Render<T>> Picker<T, R> {
    fn render<'a>(&self, item: &'a T) -> <R as Render<T>>::Str<'a> {
        // now we can internally render items for display
        self.renderer.render(item)
    }
}
```
Note that the return type of `Picker::render` cannot actually be `&'a str`, since it is possible that the `render` implementation could return a type which requires ownership (such as a `String`), and then calling `as_ref()` will return a reference to local variable which is immediately dropped.

Now, for instance, if we want to render a value in terms of its `Display` implementation, we can implement a renderer for it:
```rust
pub struct DisplayRenderer;

impl<T: ToString> Render<T> for DisplayRenderer {
    type Str<'a>
        = String
    where
        T: 'a;

    fn render<'a>(&self, item: &'a T) -> Self::Str<'a> {
        item.to_string()
    }
}
```
And in situations when the output might borrow from the item, this is permitted using the associated lifetime:
```rust
pub struct PathRenderer;

impl<T: AsRef<Path>> Render<T> for PathRenderer {
    type Str<'a>
        = Cow<'a, str>
    where
        T: 'a;

    fn render<'a>(&self, item: &'a T) -> Self::Str<'a> {
        item.as_ref().to_string_lossy()
    }
}
```
The main downside of this solution is that it is quite a bit more verbose than the closure syntax.
In particular, we lose out on closure features such as automatic variable capturing.

However, we still have a final trick: we can implement `Render<T>` for closure types!
```rust
impl<T, R: for <'a> Fn(&'a T) -> Cow<'a, str>> Render<T> for R {
    type Str<'a>
        = Cow<'a, str>
    where
        T: 'a;

    fn render<'a>(&self, item: &'a T) -> Self::Str<'a> {
        self(item)
    }
}
```
Now whenever a `Render<T>` implementation is expected, the caller can also pass an appropriate closure.

### Comparison with other solutions
To conclude, let's briefly go over the previous concerns with the other solutions in relation to the implementation in this section.
Some of the details in this section will go into some other implementation choices specific to `nucleo-picker`.

#### Overhead to keep track of items
Since this implementation is generic over the item type, we can take ownership of the item internally, keep track of the association between items and the match context, and then return (a reference to) the original item to the user when complete.

#### Conversion overhead
Since we are not exposing any types into which the user should convert their data, there is no additional development overhead.

#### Extra memory overhead with lossy representation
In principle, we still have memory overhead if we want an internal representation.
In order to avoid the overhead from additionally storing the rendered representation, in `nucleo-picker`, we assume that the `Render` implementation is relatively efficient and simply call it again if the internal representation happens to be lossy (which is only the case in the presence of non-ASCII Unicode characters).
This is reasonable since we only need to call `render` to generate the items which would actually be visible on the screen, which means that there is not too much pressure for optimized render performance.

If render performance is exceptionally bad{% inline_note() %}A generous back-of-the-envelope calculation says, if we want 60 frames per second, and the terminal has 100 lines, then the render call should take on average 0.1 ms, which is an eternity from the perspective of your computer.{% end %}, unfortunately in this situation the library user will probably have to implement a custom wrapper type which internally caches the rendered representation.
```rust
pub struct CachedItem<D> {
    data: D,
    /// the pre-computed rendered version of `data`
    rendered: String,
}

pub struct CachedItemRenderer;

impl<D> Render<CachedItem<D>> for CachedItemRenderer {
    type Str<'a>
        = &'a str
    where
        D: 'a;

    fn render<'a>(&self, item: &'a Item<D>) -> Self::Str<'a> {
        &item.rendered
    }
}
```
However, since `Render` is only called a relatively low number of times per frame, in practice this should rarely be an issue.

#### Implementation on foreign types
Implementation on some foreign type `T` is now easy simply by implementing the relevant `Render<T>` implementation.
Of course, there is still boilerplate required to deal with the foreign type.
However, the key difference here is that the boilerplate is *restricted to the `Render` implementation*: when you implement a newtype wrapper, the boilerplate corrupts every downstream method call with `my_struct.0.method()` and introduces additional conversions to and from the relevant types.
After you implement `Render<T>`, you can proceed to forget about any types you needed to introduce to handle rendering.

#### Difficulty in default implementation
Default implementation is simple just by defining a new `Render` trait, and does not require the user to wrap their own types in a wrapper.
Changing the render behaviour does not require modifying `T`, and just needs a new `Render` implementation.
Since `Render` is otherwise entirely independent, one could in principle even depend on `Render` implementations from entirely different crates.

#### Inflexibility with stateful rendering patterns
Since the `Render` implementation can internally contain (dynamic) state for rendering, stateful rendering patterns are simple to implement.
The example from the earlier section would become:
```rust
struct SubsetRenderer {
    alllowed_fields: HashSet<String>,
}

impl Render<BTreeMap<String, String>> for SubsetRenderer {
    type Str<'a> = String;

    fn render<'a>(&self, item: &'a BTreeMap<String, String>) -> Self::Str<'a> {
        item.iter()
            .filter(|(k, _)| self.allowed_fields.contains(k.as_str()))
            .map(|(_, v)| v)
            .join(", ")
            .into()
    }
}
```

#### Inflexible return type
The return type is fully flexible and can be chosen by the user depending on the requirements for rendering the specific type.
The lifetime in the associated type ensures that the rendered value can borrow from the item, if such an optimization is relevant to the `Render` implementation.

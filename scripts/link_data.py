def get_link(entry, name):
    """Return the URL for a named link, or None when it is absent."""
    return next(
        (link["url"] for link in entry.get("links", []) if link["name"] == name),
        None,
    )

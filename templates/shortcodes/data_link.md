{% import "macros/data_links.html" as linker %}
{% set data = load_data(path=path) %}
{{ linker::data_link(key=key, data=data, attr=attr) }}

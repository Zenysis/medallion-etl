-- Use a custom +schema value verbatim instead of dbt's default
-- "<target.schema>_<custom>" prefixing, so that e.g. +schema: public lands in `public`.
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}

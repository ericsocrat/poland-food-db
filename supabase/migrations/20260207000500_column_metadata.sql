-- 20260207000500_column_metadata.sql
-- Purpose: Create a data dictionary (column legend) table.
-- Each row describes one column from the schema — display label, description,
-- data type, unit, expected values, and a short tooltip for future UI hover.

SET search_path = public;

CREATE TABLE IF NOT EXISTS public.column_metadata (
    id              serial PRIMARY KEY,
    table_name      text NOT NULL,
    column_name     text NOT NULL,
    display_label   text NOT NULL,
    description     text NOT NULL,
    data_type       text NOT NULL,
    unit            text,               -- e.g. 'g', 'kcal', '%', NULL
    value_range     text,               -- e.g. '0-100', 'A-E', 'YES/NO'
    example_values  text,               -- e.g. 'Dairy, Chips, Meat'
    tooltip_text    text,               -- short hover-tooltip for future UI
    category_group  text NOT NULL,      -- e.g. 'Identity', 'Nutrition', 'Scoring'
    sort_order      integer DEFAULT 0,  -- display ordering within group
    UNIQUE(table_name, column_name)
);

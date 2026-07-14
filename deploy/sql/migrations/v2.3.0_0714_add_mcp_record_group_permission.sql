-- v2.3.0_0714_add_mcp_record_group_permission.sql
-- Add group-based permission columns to mcp_record_t

ALTER TABLE nexent.mcp_record_t ADD COLUMN IF NOT EXISTS group_ids VARCHAR;
ALTER TABLE nexent.mcp_record_t ADD COLUMN IF NOT EXISTS ingroup_permission VARCHAR(30);

-- Backfill: set existing MCP records to be visible and editable by all groups.
-- New records will use the per-group permission model from the UI.
UPDATE nexent.mcp_record_t m
SET
    ingroup_permission = 'EDIT',
    group_ids = (
        SELECT string_agg(g.group_id::text, ',' ORDER BY g.group_id)
        FROM nexent.tenant_group_info_t g
        WHERE g.tenant_id = m.tenant_id
    )
WHERE m.delete_flag != 'Y'
  AND (m.group_ids IS NULL OR m.group_ids = '');

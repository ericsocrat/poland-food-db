-- Add missing index on notification_queue.product_id FK column
-- (fixes QA check: "FK columns referencing products are indexed")
CREATE INDEX IF NOT EXISTS idx_notification_queue_product
    ON notification_queue(product_id);

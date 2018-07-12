

SELECT p.shipment_id,
       s.order_id,
       Date_part('day', localtimestamp - Max(p.proof_event_date)) AS
       days_since_last_proof_sent,
   case when o.external_order_id is null then '0' else o.external_order_id end
FROM   shipment s,
       proof_history p,
       order_shipment os,
       orders o
WHERE  s.shipment_id = p.shipment_id
       AND os.shipment_id = s.shipment_id
       AND o.order_id = s.order_id
       AND p.history_type = 'sent'
       AND Coalesce(os.proof_approved_date :: text, '') = ''
       AND Coalesce(os.expected_delivery_date :: text, '') = ''
       AND ( Coalesce(s.is_cancelled :: text, '') = ''
              OR s.is_cancelled = 0 )
       AND ( Coalesce(s.tracking_num :: text, '') = ''
             AND os.tracknum_received = 0
              OR Coalesce(os.tracknum_received :: text, '') = '' )
GROUP  BY p.shipment_id,
          s.order_id,
        external_order_id
ORDER  BY days_since_last_proof_sent DESC;
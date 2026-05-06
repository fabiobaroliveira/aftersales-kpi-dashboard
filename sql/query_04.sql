SET search_path TO aftersales;

-- ============================================================
-- 4. FUNIL DE RECOMPRA
-- Pergunta: Qual % dos clientes fiéis comprou um novo veículo?
-- ============================================================
WITH base_clientes AS (
    SELECT COUNT(DISTINCT sk_cliente)   AS total_clientes
    FROM dim_cliente
),
com_visita AS (
    SELECT COUNT(DISTINCT sk_cliente)   AS total
    FROM fato_atendimento
    WHERE status_os = 'Concluída'
),
recorrentes AS (
    SELECT COUNT(*) AS total
    FROM (
        SELECT sk_cliente
        FROM fato_atendimento
        WHERE status_os = 'Concluída'
        GROUP BY sk_cliente
        HAVING COUNT(*) >= 2
    ) t
),
fieis AS (
    SELECT COUNT(*) AS total
    FROM (
        SELECT sk_cliente
        FROM fato_atendimento
        WHERE status_os = 'Concluída'
        GROUP BY sk_cliente
        HAVING COUNT(*) >= 3
    ) t
),
recompradores AS (
    SELECT COUNT(DISTINCT sk_cliente)   AS total
    FROM fato_recompra
)
SELECT
    b.total_clientes                                AS base_total,
    v.total                                         AS com_visita,
    r.total                                         AS recorrentes,
    f.total                                         AS fieis,
    rc.total                                        AS recompradores,
    ROUND(v.total  * 100.0 / b.total_clientes, 1)   AS pct_com_visita,
    ROUND(r.total  * 100.0 / b.total_clientes, 1)   AS pct_recorrentes,
    ROUND(f.total  * 100.0 / b.total_clientes, 1)   AS pct_fieis,
    ROUND(rc.total * 100.0 / b.total_clientes, 1)   AS pct_recompra
FROM base_clientes b, com_visita v,
     recorrentes r, fieis f, recompradores rc;

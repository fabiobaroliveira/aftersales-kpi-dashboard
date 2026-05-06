SET search_path TO aftersales;

-- ============================================================
-- 3. RETENÇÃO DE CLIENTES
-- Pergunta: Quantas visitas cada cliente fez? Quem está em risco?
-- ============================================================
WITH visitas_por_cliente AS (
    SELECT
        cl.sk_cliente,
        cl.id_cliente,
        cl.segmento_cliente,
        cl.canal_aquisicao,
        cl.uf_cliente,
        COUNT(f.sk_os)                AS qtd_visitas,
        MIN(t.data)                   AS primeira_visita,
        MAX(t.data)                   AS ultima_visita,
        ROUND(SUM(f.vlr_total_os), 2) AS valor_lifetime
    FROM dim_cliente cl
    LEFT JOIN fato_atendimento f ON cl.sk_cliente = f.sk_cliente
                                AND f.status_os   = 'Concluída'
    LEFT JOIN dim_tempo t        ON f.sk_tempo     = t.sk_tempo
    GROUP BY
        cl.sk_cliente, cl.id_cliente,
        cl.segmento_cliente, cl.canal_aquisicao, cl.uf_cliente
)
SELECT
    *,
    CASE
        WHEN qtd_visitas = 0 THEN 'Churn'
        WHEN qtd_visitas = 1 THEN 'Em Risco'
        WHEN qtd_visitas = 2 THEN 'Recorrente'
        ELSE 'Fiel'
    END                               AS classificacao_retencao
FROM visitas_por_cliente
ORDER BY qtd_visitas DESC;

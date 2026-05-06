SET search_path TO aftersales;

-- ============================================================
-- 6. CSAT POR REGIÃO E CANAL
-- Pergunta: Onde a qualidade está abaixo da meta (4.0)?
-- ============================================================
SELECT
    c.regiao,
    c.canal,
    COUNT(f.sk_os)                                  AS qtd_os,
    ROUND(AVG(f.csat), 2)                           AS csat_medio,
    SUM(CASE WHEN f.csat >= 4 THEN 1 ELSE 0 END)    AS notas_positivas,
    SUM(CASE WHEN f.csat <= 2 THEN 1 ELSE 0 END)    AS notas_criticas,
    ROUND(
        SUM(CASE WHEN f.csat >= 4 THEN 1 ELSE 0 END)::NUMERIC /
        NULLIF(COUNT(f.sk_os), 0) * 100
    , 1)                                            AS pct_notas_positivas,
    CASE
        WHEN AVG(f.csat) >= 4.3 THEN 'Acima da meta'
        WHEN AVG(f.csat) >= 4.0 THEN 'Na meta'
        ELSE 'Abaixo da meta'
    END                                             AS status_qualidade
FROM fato_atendimento f
JOIN dim_concessionaria c ON f.sk_concessionaria = c.sk_concessionaria
WHERE f.status_os = 'Concluída'
GROUP BY c.regiao, c.canal
ORDER BY csat_medio DESC;

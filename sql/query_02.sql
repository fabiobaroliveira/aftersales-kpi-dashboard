SET search_path TO aftersales;

-- ============================================================
-- 2. RANKING DE CONCESSIONÁRIAS
-- Pergunta: Quais dealers lideram em receita, margem e CSAT?
-- ============================================================
SELECT
    c.id_concessionaria,
    c.nome_concessionaria,
    c.regiao,
    c.uf,
    c.canal,
    c.porte,
    COUNT(f.sk_os)                              AS qtd_os,
    ROUND(SUM(f.vlr_total_os), 2)               AS receita_total,
    ROUND(AVG(f.vlr_total_os), 2)               AS ticket_medio,
    ROUND(SUM(f.margem_bruta_pecas), 2)         AS margem_total,
    ROUND(AVG(f.csat), 2)                       AS csat_medio,
    ROUND(AVG(f.tempo_atendimento_h), 1)        AS tempo_medio_h,
    SUM(CASE WHEN f.retornou_30d THEN 1 ELSE 0 END) AS retornos_30d,
    ROUND(
        SUM(CASE WHEN f.retornou_30d THEN 1 ELSE 0 END)::NUMERIC /
        NULLIF(COUNT(f.sk_os), 0) * 100
    , 1)                                        AS taxa_retrabalho_pct
FROM fato_atendimento f
JOIN dim_concessionaria c ON f.sk_concessionaria = c.sk_concessionaria
WHERE f.status_os = 'Concluída'
GROUP BY
    c.id_concessionaria, c.nome_concessionaria,
    c.regiao, c.uf, c.canal, c.porte
ORDER BY receita_total DESC;

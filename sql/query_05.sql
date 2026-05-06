SET search_path TO aftersales;

-- ============================================================
-- 5. MIX DE SERVIÇOS — Margem por Categoria
-- Pergunta: Quais serviços são mais rentáveis para a rede?
-- ============================================================
SELECT
    s.categoria_servico,
    s.nome_servico,
    s.complexidade,
    COUNT(f.sk_os)                              AS qtd_os,
    ROUND(AVG(f.vlr_total_os), 2)               AS ticket_medio,
    ROUND(SUM(f.vlr_total_os), 2)               AS receita_total,
    ROUND(SUM(f.margem_bruta_pecas), 2)         AS margem_total,
    ROUND(
        SUM(f.margem_bruta_pecas) /
        NULLIF(SUM(f.vlr_pecas_sellout), 0) * 100
    , 1)                                        AS margem_pct,
    ROUND(AVG(f.csat), 2)                       AS csat_medio
FROM fato_atendimento f
JOIN dim_servico s ON f.sk_servico = s.sk_servico
WHERE f.status_os = 'Concluída'
GROUP BY s.categoria_servico, s.nome_servico, s.complexidade
ORDER BY margem_total DESC;

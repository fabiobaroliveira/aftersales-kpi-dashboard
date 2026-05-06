SET search_path TO aftersales;

-- ============================================================
-- 1. RECEITA MENSAL — Sell-in vs Sell-out
-- Pergunta: Como está evoluindo a receita e a margem mês a mês?
-- ============================================================
SELECT
    t.ano,
    t.mes_num,
    t.mes_nome,
    COUNT(f.sk_os)                              AS qtd_os,
    ROUND(SUM(f.vlr_total_os), 2)               AS receita_total,
    ROUND(SUM(f.vlr_pecas_sellout), 2)          AS sellout_pecas,
    ROUND(SUM(f.vlr_pecas_sellin), 2)           AS sellin_pecas,
    ROUND(SUM(f.margem_bruta_pecas), 2)         AS margem_bruta,
    ROUND(
        SUM(f.margem_bruta_pecas) /
        NULLIF(SUM(f.vlr_pecas_sellout), 0) * 100
    , 1)                                        AS margem_pct
FROM fato_atendimento f
JOIN dim_tempo t ON f.sk_tempo = t.sk_tempo
WHERE f.status_os = 'Concluída'
GROUP BY t.ano, t.mes_num, t.mes_nome
ORDER BY t.ano, t.mes_num;

-- ============================================================
-- Banco: PostgreSQL / SQL Server / BigQuery 
-- Atualizado: 2024
-- ============================================================

-- ============================================================
-- DIMENSÕES
-- ============================================================

-- Dimensão Tempo
CREATE TABLE dim_tempo (
    sk_tempo        INT             PRIMARY KEY,
    data            DATE            NOT NULL,
    ano             INT             NOT NULL,
    semestre        VARCHAR(2)      NOT NULL,   -- 'S1', 'S2'
    trimestre       VARCHAR(2)      NOT NULL,   -- 'Q1', 'Q2', 'Q3', 'Q4'
    mes_num         INT             NOT NULL,
    mes_nome        VARCHAR(20)     NOT NULL,
    semana_ano      INT             NOT NULL,
    dia_semana      VARCHAR(20)     NOT NULL,
    is_fim_semana   BOOLEAN         NOT NULL
);

-- Dimensão Concessionária
CREATE TABLE dim_concessionaria (
    sk_concessionaria   INT             PRIMARY KEY,
    id_concessionaria   VARCHAR(10)     NOT NULL,
    nome_concessionaria VARCHAR(100)    NOT NULL,
    cidade              VARCHAR(100)    NOT NULL,
    uf                  CHAR(2)         NOT NULL,
    regiao              VARCHAR(20)     NOT NULL,
    canal               VARCHAR(30)     NOT NULL,
    -- 'Dealer Oficial', 'Dealer Autorizado', 'Multimarca'
    porte               VARCHAR(10)     NOT NULL,
    -- 'Grande', 'Médio', 'Pequeno'
    meta_anual_servicos INT             NOT NULL
);

-- Dimensão Cliente
CREATE TABLE dim_cliente (
    sk_cliente          INT             PRIMARY KEY,
    id_cliente          VARCHAR(10)     NOT NULL,
    nome_cliente        VARCHAR(100)    NOT NULL,
    segmento_cliente    VARCHAR(30)     NOT NULL,
    -- 'PF - Varejo', 'PF - Premium', 'PJ - Frota Pequena', 'PJ - Frota Grande'
    canal_aquisicao     VARCHAR(30)     NOT NULL,
    uf_cliente          CHAR(2)         NOT NULL,
    data_cadastro       DATE            NOT NULL,
    faixa_etaria        VARCHAR(10)     NOT NULL,
    ativo               BOOLEAN         NOT NULL DEFAULT TRUE
);

-- Dimensão Veículo
CREATE TABLE dim_veiculo (
    sk_veiculo          INT             PRIMARY KEY,
    modelo              VARCHAR(50)     NOT NULL,
    tipo_carroceria     VARCHAR(20)     NOT NULL,
    combustivel         VARCHAR(20)     NOT NULL,
    segmento            VARCHAR(20)     NOT NULL,
    ano_modelo          INT             NOT NULL,
    faixa_preco         VARCHAR(10)     NOT NULL
    -- 'Entrada', 'Médio', 'Premium'
);

-- Dimensão Serviço
CREATE TABLE dim_servico (
    sk_servico                  INT             PRIMARY KEY,
    nome_servico                VARCHAR(50)     NOT NULL,
    categoria_servico           VARCHAR(30)     NOT NULL,
    complexidade                VARCHAR(10)     NOT NULL,
    -- 'Baixo', 'Médio', 'Alto'
    preco_medio_mao_obra_min    NUMERIC(10,2)   NOT NULL,
    preco_medio_mao_obra_max    NUMERIC(10,2)   NOT NULL,
    gera_recompra               BOOLEAN         NOT NULL DEFAULT FALSE
);

-- ============================================================
-- TABELAS FATO
-- ============================================================

-- Fato Atendimento (Ordens de Serviço)
CREATE TABLE fato_atendimento (
    sk_os                   INT             PRIMARY KEY,
    id_os                   VARCHAR(10)     NOT NULL,

    -- Chaves estrangeiras para as dimensões
    sk_tempo                INT             NOT NULL,
    sk_concessionaria       INT             NOT NULL,
    sk_veiculo              INT             NOT NULL,
    sk_servico              INT             NOT NULL,
    sk_cliente              INT             NOT NULL,

    -- Métricas financeiras
    vlr_mao_obra            NUMERIC(10,2)   NOT NULL,
    vlr_pecas_sellout       NUMERIC(10,2)   NOT NULL,  -- faturado ao cliente
    vlr_pecas_sellin        NUMERIC(10,2)   NOT NULL,  -- custo de aquisição
    vlr_total_os            NUMERIC(10,2)   NOT NULL,
    margem_bruta_pecas      NUMERIC(10,2)   NOT NULL,

    -- Métricas operacionais
    tempo_atendimento_h     INT             NOT NULL,
    csat                    INT             NOT NULL    CHECK (csat BETWEEN 1 AND 5),
    retornou_30d            BOOLEAN         NOT NULL DEFAULT FALSE,
    status_os               VARCHAR(20)     NOT NULL,
    -- 'Concluída', 'Em Aberto', 'Cancelada'

    -- Constraints de integridade referencial
    CONSTRAINT fk_fat_tempo          FOREIGN KEY (sk_tempo)          REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fat_concessionaria FOREIGN KEY (sk_concessionaria) REFERENCES dim_concessionaria(sk_concessionaria),
    CONSTRAINT fk_fat_veiculo        FOREIGN KEY (sk_veiculo)        REFERENCES dim_veiculo(sk_veiculo),
    CONSTRAINT fk_fat_servico        FOREIGN KEY (sk_servico)        REFERENCES dim_servico(sk_servico),
    CONSTRAINT fk_fat_cliente        FOREIGN KEY (sk_cliente)        REFERENCES dim_cliente(sk_cliente)
);

-- Fato Recompra
CREATE TABLE fato_recompra (
    sk_recompra         INT             PRIMARY KEY,
    sk_cliente          INT             NOT NULL,
    sk_tempo            INT             NOT NULL,
    sk_veiculo_novo     INT             NOT NULL,
    sk_concessionaria   INT             NOT NULL,
    vlr_veiculo         NUMERIC(12,2)   NOT NULL,
    canal_venda         VARCHAR(20)     NOT NULL,
    financiado          BOOLEAN         NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_rec_cliente        FOREIGN KEY (sk_cliente)        REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_rec_tempo          FOREIGN KEY (sk_tempo)          REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_rec_veiculo        FOREIGN KEY (sk_veiculo_novo)   REFERENCES dim_veiculo(sk_veiculo),
    CONSTRAINT fk_rec_concessionaria FOREIGN KEY (sk_concessionaria) REFERENCES dim_concessionaria(sk_concessionaria)
);

-- ============================================================
-- ÍNDICES — otimização de performance para queries analíticas
-- ============================================================

CREATE INDEX idx_fat_tempo          ON fato_atendimento(sk_tempo);
CREATE INDEX idx_fat_concessionaria ON fato_atendimento(sk_concessionaria);
CREATE INDEX idx_fat_cliente        ON fato_atendimento(sk_cliente);
CREATE INDEX idx_fat_servico        ON fato_atendimento(sk_servico);
CREATE INDEX idx_fat_status         ON fato_atendimento(status_os);
CREATE INDEX idx_rec_cliente        ON fato_recompra(sk_cliente);
CREATE INDEX idx_rec_tempo          ON fato_recompra(sk_tempo);

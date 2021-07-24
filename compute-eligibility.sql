

--drop table pigy_class;

create temporary table pigy_class (
  range     varchar(20) not null
, reward    bigint      not null
, stake_min bigint      not null
, stake_max bigint      not null
);

insert into pigy_class values
  ('≤ 10'       ,   1001,             1,        10000000)
, ('≤ 100'      ,   2000,      10000001,       100000000)
, ('≤ 1 000'    ,   3000,     100000001,      1000000000)
, ('≤ 10 000'   ,   5000,    1000000001,     10000000000)
, ('≤ 100 000'  ,  10000,   10000000001,    100000000000)
, ('≤ 1 000 000',  50000,  100000000001,   1000000000000)
, ('> 1 000 000', 100000, 1000000000001, 999999990000009)
;


--drop table pigy_ticker;

create temporary table pigy_ticker (
  ticker varchar(20) not null
, pool_hash varchar(64) not null
, spo bool not null
);

\copy pigy_ticker from 'pigy_ticker.csv' csv


--drop table pigy_pools;

create temporary table pigy_pools as
select
    ticker
  , pool_hash
  , view as pool_address
  , id as pool_id
  from pigy_ticker
  inner join pool_hash
    on substr(hash_raw :: char(66), 3) = pool_hash
;


--drop table "Eligibility";

create temporary table "Eligibility" as
select
    pp.pool_hash                                                 as "Pool Hash"
  , pp.pool_address                                              as "Pool Address"
  , pp.ticker                                                    as "Pool Ticker"
  , epoch_no                                                     as "Epoch No"
  , substr(d.hash_raw :: char(66), 5)                            as "Stake Hash"
  , stake_address                                                as "Stake Address"
  , d.active_epoch_no                                            as "First Epoch"
  , epoch_no - d.active_epoch_no + 1                             as "Number of Epochs"
  , ltrim(to_char(amount / 1000000, '999 999 999 990.000000'))   as "Staked ADA"
  , range                                                        as "PIGY Range"
  from (
    select
        addr_id
      , hash_raw
      , view as stake_address
      , pool_hash_id as pool_id
      , active_epoch_no
      , row_number() over (partition by s.view order by active_epoch_no desc) as rn
    from delegation d
    inner join stake_address s
      on d.addr_id = s.id
  ) d
  inner join pigy_pools pp
    using (pool_id)
  inner join epoch_stake
    using (pool_id, addr_id)
  inner join pigy_class
    on amount between stake_min and stake_max
  where rn = 1
    and epoch_no = (select max(epoch_no) from epoch_stake)
--  and d.active_epoch_no <= epoch_no - 3
  order by "Pool Ticker", "Pool Address", amount desc
;

\copy "Eligibility" to 'Eligibility.csv' csv header


--drop table pigy_duraction;

create temporary table pigy_duration as
select
    addr_id
  , pool_id
  , sum(                                       1           ) as epochs
  , sum(case when amount >    50000000000 then 1 else 0 end) as epochs_50k
  , sum(case when amount >   100000000000 then 1 else 0 end) as epochs_100k
  , sum(case when amount >  1000000000000 then 1 else 0 end) as epochs_1m
  , sum(case when amount >  5000000000000 then 1 else 0 end) as epochs_5m
  , sum(case when amount > 10000000000000 then 1 else 0 end) as epochs_10m
  from epoch_stake s
  inner join pigy_pools pp
    using (pool_id)
  where epoch_no > (select max(epoch_no) from epoch_stake) - 20
  group by addr_id, pool_id
;


--drop table pigy_game;

create temporary table pigy_game as
  select
      substr(sa.hash_raw :: char(66), 5) as "Stake Hash"
    , sa.view as "Stake Address"
    , sum(epochs) as "PIGY Epochs"
    , sum(1) as "PIGY Pools"
    , case when sum(case when epochs      >=  4 then 1 else 0 end) >=  3 then '✔' else '' end as "Pool Hopper"
    , case when sum(case when epochs_50k  >=  4 then 1 else 0 end) >= 10 then '✔' else '' end as "Extreme Hopper"
    , case when sum(case when epochs_100k >= 10 then 1 else 0 end) >=  1 then '✔' else '' end as "Pool Fest"
    , case when sum(case when epochs_1m   >= 10 then 1 else 0 end) >=  1 then '✔' else '' end as "The Golden Pool"
    , case when sum(case when epochs_5m   >= 20 then 1 else 0 end) >=  1 then '✔' else '' end as "The Richie Rich"
    , case when sum(case when epochs_10m  >= 20 then 1 else 0 end) >=  1 then '✔' else '' end as "The Sultan of Cardano"
    , case when sum(case when epochs_10m  >= 20 then 1 else 0 end) >= 20 then '✔' else '' end as "The Collector"
    from pigy_duration pd
    inner join stake_address sa
      on sa.id = pd.addr_id
    group by sa.hash_raw, sa.view
    order by 1
;


\copy (select * from pigy_game where "Pool Hopper" = '✔' or "Extreme Hopper" = '✔' or "Pool Fest" = '✔' or "The Golden Pool" = '✔' or "The Richie Rich" = '✔' or "The Sultan of Cardano" = '✔' or "The Collector" = '✔' order by 5 desc, 6 desc, 7 desc, 8 desc, 9 desc, 10 desc, 11 desc, 1) to 'pages/game-winners-last20epochs.csv' csv header

\copy (select * from pigy_game order by 1) to 'pages/game-all-last20epochs.csv' csv header


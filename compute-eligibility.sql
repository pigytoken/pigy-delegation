

drop table pigy_ticker;

create temporary table pigy_ticker (
  ticker varchar(20) not null
);

\copy pigy_ticker from 'pigy_ticker.csv' csv


drop table pool_ticker_scraped;

create temporary table pool_ticker_scraped (
  hash   char(64)    not null
, ticker varchar(20) not null
);

\copy pool_ticker_scraped from 'pool_ticker_scraped.csv' csv


drop table pool_ticker;

create temporary table pool_ticker (
  hash   char(64)    not null
, ticker varchar(20) not null
);

\copy pool_ticker from 'pool_ticker.csv' csv


drop table pool_ticker_missing;

create temporary table pool_ticker_missing as
select
  'curl --connect-timeout 15 -o pool_meta/'
    || substr(hash :: char(66), 3)
    || '.json "'
    || url
    || '"'
  from pool_meta_data
  where substr(hash :: char(66), 3) not in (
    select hash
      from pool_ticker
  )
;

\copy pool_ticker_missing to 'pool_ticker_missing.sh'


drop table pigy_class;

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


drop table pool_ticker_active;

create temporary table pool_ticker_active as
select pool_id, ticker
  from (
    select
        pu.hash_id as pool_id
      , substr(pm.hash :: char(66), 3) as hash
      , row_number() over (partition by pu.hash_id order by active_epoch_no desc) as rn
      from pool_update pu
      inner join pool_meta_data pm
        on pu.meta_id = pm.id
      inner join pool_hash ph
        on ph.id = pu.hash_id
  ) p
  inner join pool_ticker pt
    using (hash)
  where rn = 1
union
select ph.id as pool_id, ticker
  from pool_hash ph
  inner join pool_ticker_scraped ps
    on substr(ph.hash_raw :: char(66), 3) = ps.hash
;


drop table "Eligibility";

create temporary table "Eligibility" as
select
    substr(ph.hash_raw :: char(66), 3)                         as "Pool Hash"
  , ph.view                                                    as "Pool Address"
  , coalesce(pt.ticker, '')                                    as "Pool Ticker"
  , epoch_no                                                   as "Epoch No"
  , substr(a.hash_raw :: char(66), 5)                          as "Stake Hash"
  , stake_address                                              as "Stake Address"
  , a.active_epoch_no                                          as "Stake Epoch No"
  , ltrim(to_char(amount / 1000000, '999 999 999 990.000000')) as "Staked ADA"
  , range                                                      as "PIGY Range"
  , pt.ticker in (select ticker from pigy_ticker)              as "PIGY Pool?"
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
  ) a
  inner join pool_hash ph
    on ph.id = a.pool_id
  inner join epoch_stake
    using (pool_id, addr_id)
  inner join pigy_class
    on amount between stake_min and stake_max
  left join pool_ticker_active pt
    using (pool_id)
  where rn = 1
    and epoch_no = 273
    and a.active_epoch_no <= epoch_no - 3
  order by "PIGY Pool?" desc, pt.ticker = '[n/a]' or pt.ticker is null, "Pool Ticker", "Pool Address", amount desc
;

select "Pool Hash"
  from "Eligibility"
  where "Pool Ticker" = ''
;

\copy "Eligibility" to 'Eligibility.csv' csv header


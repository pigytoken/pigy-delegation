
--drop table pigy_tx_out;

create temporary table pigy_tx_out as
select
    tx_id as tx_out_id
  , index as tx_out_index
  , address as address_out
  , stake_address.view as stake_address_out
  , coalesce(pool_hash.view, stake_address.view, address) as source
  , quantity as pigy
  from ma_tx_out
  inner join tx_out
    on tx_out_id = tx_out.id
  left join stake_address
    on stake_address_id = stake_address.id
  left join pool_owner
    on pool_owner.id = stake_address.id
  left join pool_hash
    on pool_hash.id = pool_hash_id
  where substr(policy :: varchar(66), 3) = '2aa9c1557fcf8e7caa049fa0911a8724a1cdaf8037fe0b431c6ac664'
order by 1
;


--drop table pigy_first;

create temporary table pigy_first as
select
    row_number() over(order by tx_out_id) as pigy_first
  , source
  from (
    select
        min(tx_out_id) as tx_out_id
      , source
      from pigy_tx_out
      group by source
    ) p
;


--drop table pigy_tx;

create temporary table pigy_tx as
select
    id as tx_id
  , substr(hash :: varchar(66), 3) as tx_hash
  from tx
  where id in (select tx_out_id from pigy_tx_out)
order by 1
;


--drop table pigy_tx_in;

create temporary table pigy_tx_in as
select
    tx_in_id
  , tx_out_id
  , tx_out_index
  from tx_in
  where tx_in_id  in (select tx_out_id from pigy_tx_out)
    or  tx_out_id in (select tx_out_id from pigy_tx_out)
order by 1
;

select
    c.tx_in_id
  from pigy_tx_in c
  inner join pigy_tx_out a
    on  a.tx_out_id    = c.tx_out_id
    and a.tx_out_index = c.tx_out_index
  group by c.tx_in_id
  having count(distinct a.source) > 1
;


--drop table pigy_history;

create temporary table pigy_history as
select distinct
    f.pigy_first                       as "Order of First PIGY Receipt"
  , a.source                           as "From Address"
  , b.source                           as "To Address"
  , to_char(b.pigy, '99 999 999 999')  as "PIGY"
  , d.tx_hash || '#' || b.tx_out_index as "Transaction"
  , d.tx_id                            as "Order of Transactions"
  from pigy_tx_in c
  inner join pigy_tx_out a
    on  a.tx_out_id    = c.tx_out_id
    and a.tx_out_index = c.tx_out_index
  inner join pigy_tx_out b
    on b.tx_out_id = c.tx_in_id
  inner join pigy_first f
    on a.source = f.source
  inner join pigy_tx d
    on b.tx_out_id = d.tx_id
  where a.source != b.source
order by 1, 6
;


\copy pigy_history to pigy-history.csv csv header quote '"' force quote "PIGY"

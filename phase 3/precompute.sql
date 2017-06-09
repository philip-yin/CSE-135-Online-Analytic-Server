drop table temp1;
drop table temp2;
drop table temp3;
drop table log;

create table temp1(state_name text, id int, category_id int, total int);
create table temp2(state_name text, product_id int, product_name text, total int);
create table temp3(product_name text, id int, category_id int, total int);

create table log(person_id int, product_id int, total int);

insert into temp1
select state_name, id, category_id, sum(total) As total from
(select s.state_name, s.id, pr.category_id, sum(pc.quantity * pc.price) As total from
state s, person p, shopping_cart sc, products_in_cart pc, product pr
where s.id = p.state_id and sc.person_id = p.id and pc.cart_id = sc.id and sc.is_purchased = true and pc.product_id = pr.id
group by s.state_name, s.id, pr.category_id union
select s2.state_name, s2.id, 0 as category_id, 0 As total from state s2) As temp
group by state_name, id, category_id;

insert into temp2
select s.state_name, pc.product_id, pr.product_name, sum(pc.quantity * pc.price) As total from
state s, person p, shopping_cart sc, products_in_cart pc, product pr
where s.id = p.state_id and p.id = sc.person_id and sc.id = pc.cart_id and sc.is_purchased = true
and pr.id = pc.product_id group by s.state_name, pc.product_id, pr.product_name;

insert into temp3
select product_name, id, category_id, sum(total) as total from
(select pr.product_name, pr.id, pr.category_id, 0 as total from product pr union
select pr.product_name, pr.id, pr.category_id, sum(pc.quantity * pc.price) as total from
product pr, products_in_cart pc, shopping_cart sc
where sc.is_purchased = true and sc.id = pc.cart_id and pr.id = pc.product_id
group by pr.product_name, pr.id) as temp
group by product_name, id, category_id;

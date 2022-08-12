# Вывести количество фильмов в каждой категории, отсортировать по убыванию.
select category.name as category, count(fc.film_id) as num_films  from category
join film_category fc on category.category_id = fc.category_id
group by category.name
order by num_films desc;

# Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select first_name, last_name, count(rental_date) as num_rents from actor
join film_actor fa on actor.actor_id = fa.actor_id
join film f on f.film_id = fa.film_id
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by actor.actor_id
order by num_rents desc
limit 10;

# Вывести категорию фильмов, на которую потратили больше всего денег.
#

select cat, max(money_spent) from (
    select category.name as cat, sum(p.amount) as money_spent from category
    join film_category fc on category.category_id = fc.category_id
    join film f on f.film_id = fc.film_id
    join inventory i on f.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    join payment p on r.rental_id = p.rental_id
    group by category.category_id
    order by money_spent desc) as query;

# Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
select film.title from film
left join inventory on film.film_id = inventory.film_id
where inventory.film_id is null;

# Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

select first_name, last_name
from (
    select *, dense_rank() over (order by num_films desc ) rank_res
    from (
        select actor.first_name, actor.last_name, count(fa.film_id) as num_films from actor
        join film_actor fa on actor.actor_id = fa.actor_id
        join film f on f.film_id = fa.film_id
        join film_category fc on f.film_id = fc.film_id
        join category c on c.category_id = fc.category_id
        where c.name = 'Children'
        group by actor.actor_id
        order by num_films desc
        ) as query_w
    order by rank_res
    ) as query_x
where rank_res <= (select rank_res from
                                       (
                                       select num_films, dense_rank() over (order by num_films desc ) rank_res
                                       from (select actor.first_name, actor.last_name, count(fa.film_id) as num_films from actor
                                            join film_actor fa on actor.actor_id = fa.actor_id
                                            join film f on f.film_id = fa.film_id
                                            join film_category fc on f.film_id = fc.film_id
                                            join category c on c.category_id = fc.category_id
                                            where c.name = 'Children'
                                            group by actor.actor_id
                                            order by num_films desc) as query_w
                                       order by rank_res
                                       limit 2,1) as query_y );


# Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select city, active, count(customer_id) as num_cust from city
join address a on city.city_id = a.city_id
join customer c on a.address_id = c.address_id
where active = 0
group by city, active
order by active, num_cust desc;


# Вывести категорию фильмов,
# у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city),
# и которые начинаются на букву “a”.
# То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

select city, category.name,  sum(datediff(return_date, rental_date)) as hours from category
join film_category fc on category.category_id = fc.category_id
join film f on f.film_id = fc.film_id
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join customer c on c.customer_id = r.customer_id
join address a on a.address_id = c.address_id
join city c2 on c2.city_id = a.city_id
where category.name like 'a%' and city like '%-%'
group by city, category.name
order by hours desc;

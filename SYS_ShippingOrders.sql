SET SERVEROUTPUT ON;

-- find_customer
CREATE OR REPLACE PROCEDURE find_customer (
    customer_id IN NUMBER,
    found       OUT NUMBER
) AS
BEGIN
    SELECT
        1
    INTO found
    FROM
        customers
    WHERE
        customer_id = find_customer.customer_id;

EXCEPTION
    WHEN no_data_found THEN
        found := 0;
    WHEN too_many_rows THEN
        found := 0;
        dbms_output.put_line('Multiple customers found for the given customer ID.');
    WHEN OTHERS THEN
        found := 0;
        dbms_output.put_line('An error occurred while finding the customer.');
END;
/

-- find_product
CREATE OR REPLACE PROCEDURE find_product (
    productid   IN NUMBER,
    price       OUT products.list_price%TYPE,
    productname OUT products.product_name%TYPE
) AS
    categoryid products.category_id%TYPE;
BEGIN
    SELECT
        product_name,
        list_price,
        category_id
    INTO
        productname,
        price,
        categoryid
    FROM
        products
    WHERE
        product_id = productid;

    IF
        to_char(sysdate, 'MM') IN ( '11', '12' )
        AND categoryid IN ( 2, 5 )
    THEN
        price := price * 0.9;
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        productname := NULL;
        price := 0;
    WHEN too_many_rows THEN
        productname := NULL;
        price := 0;
        dbms_output.put_line('Multiple products found for the given product ID.');
    WHEN OTHERS THEN
        productname := NULL;
        price := 0;
        dbms_output.put_line('An error occurred while finding the product.');
END;
/





-- add_order
CREATE OR REPLACE PROCEDURE add_order (
    customer_id  IN NUMBER,
    new_order_id OUT NUMBER
) AS
BEGIN
    new_order_id := generate_order_id();
    INSERT INTO orders (
        order_id,
        customer_id,
        status,
        salesman_id,
        order_date
    ) VALUES (
        new_order_id,
        customer_id,
        'Shipped',
        56,
        sysdate
    );

    COMMIT;
END;
/

-- generate_order_id
CREATE OR REPLACE FUNCTION generate_order_id RETURN NUMBER AS
    new_order_id NUMBER;
BEGIN
    SELECT
        MAX(order_id) + 1
    INTO new_order_id
    FROM
        orders;

    RETURN new_order_id;
END;
/

-- add_order_item
CREATE OR REPLACE PROCEDURE add_order_item (
    orderid   IN order_items.order_id%TYPE,
    itemid    IN order_items.item_id%TYPE,
    productid IN order_items.product_id%TYPE,
    quantity  IN order_items.quantity%TYPE,
    price     IN order_items.unit_price%TYPE
) AS
BEGIN
    INSERT INTO order_items (
        order_id,
        item_id,
        product_id,
        quantity,
        unit_price
    ) VALUES (
        orderid,
        itemid,
        productid,
        quantity,
        price
    );

    COMMIT;
END;
/





-- customer_order
CREATE OR REPLACE PROCEDURE customer_order (
    customerid IN NUMBER,
    orderid    IN OUT NUMBER
) AS
BEGIN
    SELECT
        order_id
    INTO orderid
    FROM
        orders
    WHERE
            customer_id = customerid
        AND order_id = orderid;

EXCEPTION
    WHEN no_data_found THEN
        orderid := 0;
END;
/





-- display_order_status
CREATE OR REPLACE PROCEDURE display_order_status (
    orderid IN NUMBER,
    status  OUT orders.status%TYPE
) AS
BEGIN
    SELECT
        lower(status)
    INTO display_order_status.status
    FROM
        orders
    WHERE
        order_id = orderid;

EXCEPTION
    WHEN no_data_found THEN
        status := NULL;
END;
/





-- cancel_order
CREATE OR REPLACE PROCEDURE cancel_order (
    orderid      IN NUMBER,
    cancelstatus OUT NUMBER
) AS
    orderstatus orders.status%TYPE;
BEGIN
    SELECT
        status
    INTO orderstatus
    FROM
        orders
    WHERE
        order_id = orderid;

    IF orderstatus = 'Canceled' THEN
        cancelstatus := 1;
    ELSIF orderstatus = 'Shipped' THEN
        cancelstatus := 2;
    ELSE
        UPDATE orders
        SET
            status = 'Canceled'
        WHERE
            order_id = orderid;

        COMMIT;
        cancelstatus := 3;
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        cancelstatus := 0;
END;
/
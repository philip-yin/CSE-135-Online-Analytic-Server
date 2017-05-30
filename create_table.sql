CREATE TABLE USERS(
  ID SERIAL PRIMARY KEY,
  AGE INTEGER NOT NULL CHECK (AGE >= 0),
  ROLE TEXT NOT NULL,
  NAME TEXT UNIQUE NOT NULL,
  STATE TEXT NOT NULL
);

CREATE TABLE CATEGORY(
  NAME TEXT PRIMARY KEY,
  DESCRIPTION TEXT NOT NULL
);

CREATE TABLE PRODUCT(
  SKU TEXT PRIMARY KEY,
  NAME TEXT NOT NULL,
  PRICE INTEGER NOT NULL CHECK (PRICE > 0),
  CAT TEXT REFERENCES CATEGORY(NAME)
);


CREATE TABLE CART(
  ID SERIAL PRIMARY KEY,
  AMOUNT INTEGER NOT NULL CHECK (AMOUNT > 0),
  PRODUCT_ID TEXT REFERENCES PRODUCT(SKU) NOT NULL,
  USER_ID SERIAL REFERENCES USERS(ID) NOT NULL
);

CREATE TABLE PURCHASE(
  ID SERIAL PRIMARY KEY,
  PRODUCT_ID TEXT REFERENCES PRODUCT(SKU) NOT NULL,
  AMOUNT INTEGER NOT NULL CHECK (AMOUNT > 0),
  PRICE INTEGER NOT NULL CHECK (PRICE > 0),
  PURCHASEDATE DATE NOT NULL,
  USER_ID SERIAL REFERENCES USERS(ID) NOT NULL
);
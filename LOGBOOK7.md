# Log Book 6

## Environment Setup

We successfuly changed the hosts file and ran the server using the `docker-compose` commands.


## Task 1

For this task we want to display the information of the employee 'Alice'.
We acheived this using the following query:

![LOGBOOK7_img/show_tables.png](Query)

## Task 2

### Task 2.1

The objetive of this task is to find bypass the admin's login to retreive
the information about all employes.

To achieve this, we inject the sql statement bellow:
```
username=Admin' or 'a'='a
password=123
```

Which brings us to the desired page
![LOGBOOK7_img/user_details.png](Curl Result)


### Task 2.2

The goal of this task is to achieve the last task's result from the command line.
We use the following command:
```bash
curl "www.seed-server.com/unsafe_home.php?username=Admin%27or%27a%27=%27a&Password=123"
```

Which has the following output:
![LOGBOOK7_img/curl_result.png](Curl Result)

### Task 2.3

We cannot inject two sql queries in the system.
This happens due to the use of a function that prevents the injection of two queries inside one:
the [https://www.php.net/manual/en/mysqli.query.php](mysql `query` function).
In contrast, [https://www.php.net/manual/en/mysqli.multi-query.php](mysql's `multi-query`) allows
for multiple query injection

## Task 3

### Task 3.1

The goal of this task is to change an employee status with sql injection in the
UPDATE statement.

We did this by inserting `Alice', Salary=987654321, nickname='Alice` into the nickname field.
All other fields were left blank.

The profile before running the request:
![LOGBOOK7_img/before_result.png](Before Result)

The profile after sending the request:
![LOGBOOK7_img/after_result.png](After Result)

### Task 3.2

For this task we want to set another employee's salary.
We do this by using the following request:

![LOGBOOK7_img/update_other_employee.png](Update other employee request)

As we can see, Bobby's salary was set to 1:
![LOGBOOK7_img/bobbys_salary.png](Bobby's salary)

### Task 3.3

The objetive of this task is to change a user's password.

Let's hash a new password: `superpassword`:
![LOGBOOK7_img/hash.png](Superpassoword's SHA-1 hash)

Then we can use the following request to change Bobby's password:
![LOGBOOK7_img/bobbys_password.png](Change Bobby's password)

Afterwards, we can login into Bobby's account using `superpassword` as the password
![LOGBOOK7_img/bobbys_login.png](Bobby's login)

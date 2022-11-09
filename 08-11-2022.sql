-- account_update table creation --

create table account_update(id int primary key auto_increment,
AccountNumber int not null,
changed_at timestamp,
transactionType varchar(35) not null,
old_balance numeric(10,2) not null,
new_balance numeric(10,2) not null,
transactionAmt numeric(10,2) not null);

-- accountdetails table creation --
create table accountdetails(AccountNumber int primary key,
holdername varchar(30) not null,
Balance numeric(10,2) not null
);

-- updating accountdetails table --
update accountdetails set Balance = (Balance-1000) where AccountNumber = 1000101;
update accountdetails set Balance = (Balance+1000) where AccountNumber = 1000101;

-- creating trigger for the debit operation in the accountdetails table creation and inserting the transaction details into account_update table --
delimiter $$ 
 create trigger account_update_debit  before update on accountdetails for each row 
 begin
 if(old.Balance>new.Balance) then
	insert into account_update(AccountNumber,changed_at,transactionType, old_balance ,new_balance,transactionAmt)
    values(old.AccountNumber, now(),'debit', old.Balance, new.Balance,(old.Balance-new.Balance));
    END IF;
end$$

-- droping credit and debit triggers --
drop trigger account_update_credit;
drop trigger account_update_debit;

-- creating trigger for the credit operation in the accountdetails table creation and inserting the transaction details into account_update table --
delimiter $$ 
 create trigger account_update_credit  before update on accountdetails for each row 
 begin
 if(old.Balance<new.Balance) then
	insert into account_update(AccountNumber,changed_at,transactionType, old_balance ,new_balance,transactionAmt)
    values(old.AccountNumber, now(),'credit', old.Balance, new.Balance,(new.Balance-old.Balance));
    END IF;
end$$


-- creating procedure for getting the sum of all the transaction amount (both for credit and debit) for an hour--
DELIMITER $$
CREATE PROCEDURE hour_sum (IN AccountNumber INT, OUT dtotal numeric(10,2), OUT ctotal numeric(10,2))
BEGIN
    SELECT sum(transactionAmt) INTO dtotal FROM account_update
	WHERE  transactionType= 'debit' AND AccountNumber=AccountNumber AND changed_at >= Date_sub(now(),interval 1 hour);
    
    SELECT sum(transactionAmt) INTO ctotal FROM account_update
	WHERE transactionType = 'credit' AND AccountNumber=AccountNumber AND changed_at >= Date_sub(now(),interval 1 hour);
END $$

-- droping the procedure --
DROP PROCEDURE hour_sum;

-- call the procedure --
CALL hour_sum(1000101, @dtotal, @ctotal);

-- displaying the total sum of transaction (both credit and debit)--
SELECT @dtotal, @ctotal;

Insert into Country values
    (null, 'United States/Canada', '+1'),
    (null, 'Egypt', '+20'),
    (null, 'United Kingdom', '+44');

Insert into City values
    (null, '?', (Select Code from Country where PhoneCode = '+1')),
    (null, '?', (Select Code from Country where PhoneCode = '+20')),
    (null, '?', (Select Code from Country where PhoneCode = '+44'));
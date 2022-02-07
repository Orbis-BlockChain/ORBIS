unit Translate.Core;

interface

uses
  App.Meta;

const
  { INDEX }
  Index1 = 1;
  Index2 = 2;
  Index3 = 3;
  Index4 = 4;
  Index5 = 5;
  Index6 = 6;
  Index7 = 7;
  Index8 = 8;
  Index9 = 9;
  Index10 = 10;
  Index11 = 11;
  Index12 = 12;
  Index13 = 13;
  Index14 = 14;
  Index15 = 15;
  Index16 = 16;
  Index17 = 17;
  Index18 = 18;
  Index19 = 19;
  Index20 = 20;
  Index21 = 21;
  Index22 = 22;
  Index23 = 23;
  Index24 = 24;
  Index25 = 25;
  Index26 = 26;
  Index27 = 27;
  Index28 = 28;
  Index29 = 29;
  Index30 = 30;
  Index31 = 31;
  Index32 = 32;
  Index33 = 33;
  Index34 = 34;
  Index35 = 35;
  Index36 = 36;
  Index37 = 37;
  Index38 = 38;
  Index39 = 39;
  Index40 = 40;
  Index41 = 41;
  Index42 = 42;
  Index43 = 43;
  Index44 = 44;
  Index45 = 45;
  Index46 = 46;
  Index47 = 47;
  Index48 = 48;
  Index49 = 49;
  Index50 = 50;
  Index51 = 51;
  Index52 = 52;
  Index53 = 53;
  Index54 = 54;
  Index55 = 55;
  Index56 = 56;
  Index57 = 57;
  Index58 = 58;
  Index59 = 59;
  Index60 = 60;
  Index61 = 61;
  Index62 = 62;
  Index63 = 63;
  Index64 = 64;
  Index65 = 65;
  Index66 = 66;
  Index67 = 67;
  Index68 = 68;
  Index69 = 69;
  Index70 = 70;
  Index71 = 71;
  Index72 = 72;
  Index73 = 73;
  Index74 = 74;
  Index75 = 75;
  Index76 = 76;
  Index77 = 77;
  Index78 = 78;
  Index79 = 79;
  Index80 = 80;
  Index81 = 81;
  Index82 = 82;
  Index83 = 83;
  Index84 = 84;
  Index85 = 85;
  Index86 = 86;
  Index87 = 87;
  Index88 = 88;
  Index89 = 89;
  Index90 = 90;
  Index91 = 91;
  Index92 = 92;
  Index93 = 93;
  Index94 = 94;
  Index95 = 95;
  Index96 = 96;
  Index97 = 97;
  Index98 = 98;
  Index99 = 99;
  Index100 = 100;
  Index101 = 101;
  Index102 = 102;
  Index103 = 103;
  Index104 = 104;
  Index105 = 105;
  Index106 = 106;
  Index107 = 107;
  Index108 = 108;
  Index109 = 109;
  Index110 = 110;
  Index111 = 111;
  Index112 = 112;
  Index113 = 113;
  Index114 = 114;
  Index115 = 115;
  Index116 = 116;
  Index117 = 117;
  Index118 = 118;
  Index119 = 119;
  Index120 = 120;
  Index121 = 121;
  Index122 = 122;
  Index123 = 123;
  Index124 = 124;
  Index125 = 125;
  Index126 = 126;
  Index127 = 127;
  Index128 = 128;
  Index129 = 129;
  Index130 = 130;
  Index131 = 131;
  Index132 = 132;
  Index133 = 133;
  Index134 = 134;
  Index135 = 135;
  Index136 = 136;
  Index137 = 137;
  Index138 = 138;
  Index139 = 139;
  Index140 = 140;
  Index141 = 141;
  Index142 = 142;
  Index143 = 143;
  Index144 = 144;
  Index145 = 145;
  Index146 = 146;
  Index147 = 147;
  Index148 = 148;
  Index149 = 149;

  { RU }
  PhraseRU1 = 'Генерация ORB MINING';
  PhraseRU2 = 'Количество';
  PhraseRU3 = 'Подтвердить';
  PhraseRU4 = 'Отменить';
  PhraseRU5 = 'Эту операцию будет невозможно отменить';
  PhraseRU6 = 'Перевод';
  PhraseRU7 = 'На адресс';
  PhraseRU8 = 'Комиссия';
  PhraseRU9 = 'Соединение установлено';
  PhraseRU10 = 'Создайте пароль для криптоконтейнера';
  PhraseRU11 = 'Пароль';
  PhraseRU12 = 'Повторить пароль';
  PhraseRU13 = 'ОК';
  PhraseRU14 = '(Слишком короткий пароль)';
  PhraseRU15 = '(Пароли не совпадают)';
  PhraseRU16 = 'Разрядность токена';
  PhraseRU17 = 'Стоимость выпуска токенов ORBC';
  PhraseRU18 = 'Создать токен';
  PhraseRU19 = 'Комиссия за транзакцию токена в сети ORBIS = 0 ORBC до принятия решения DAO';
  PhraseRU20 = 'Объем выпуска токенов';
  PhraseRU21 = 'Символ токена (не более 4 заглавных латинских букв)';
  PhraseRU22 = 'Название токена (любое латинскими буквами)';
  PhraseRU23 = 'Введите seed phrase';
  PhraseRU24 = 'Seed phrase от криптоконтейнера';
  PhraseRU25 = 'Назад';
  PhraseRU26 = '(Неверная seed phrase)';
  PhraseRU27 = 'Введите новый пароль для криптоконтейнера';
  PhraseRU28 = 'Файл криптоконтейнера';
  PhraseRU29 = 'Загрузить файл криптоконтейнера';
  PhraseRU30 = 'Пароль от криптоконтейнера';
  PhraseRU31 = 'Выбран файл';
  PhraseRU32 = 'Загрузить другой файл?';
  PhraseRU33 = '(Неверный пароль)';
  PhraseRU34 = 'Сделайте резервную копию кошелька прямо сейчас';
  PhraseRU35 = 'На следующем шаге Вы увидите seed phrase, которая позволяет восстановить кошелёк';
  PhraseRU36 = 'Я понимаю, что если я потеряю seed phrase я потеряю доступ к своему кошельку';
  PhraseRU37 = 'Продолжить';
  PhraseRU38 = 'Скопируйте эту seed phrase и сохраните её';
  PhraseRU39 = 'Seed phrase для восcтановления криптоконтейнера';
  PhraseRU40 = 'Далее';
  PhraseRU41 = 'Войти';
  PhraseRU42 = 'Seed phrase является мастер-ключом к вашим средствам. Никогда не делитесь ей ни с кем другим.';
  PhraseRU43 = 'ORBIS никогда не попросит Вас поделиться своей seed phrase для восстановления.';
  PhraseRU44 = 'Если Вы потеряете seed phrase для восстановления, даже ORBIS не сможет вернуть Ваши средства.';
  PhraseRU45 = 'Я понимаю риски';
  PhraseRU46 = 'Вход';
  PhraseRU47 = 'Регистрация';
  PhraseRU48 = 'Пароль от криптоконтейнера';
  PhraseRU49 = 'Криптоконтейнер';
  PhraseRU50 = 'Ввести seed phrase';
  PhraseRU51 = 'Удалить криптоконтейнер';
  PhraseRU52 = 'Мой адрес';
  PhraseRU53 = 'Скопировать адрес';
  PhraseRU54 = 'Скачать QR';
  PhraseRU55 = 'Адрес скопирован';
  PhraseRU56 = 'Отправить';
  PhraseRU57 = 'Монета/Токен:';
  PhraseRU58 = 'Баланс';
  PhraseRU60 = 'Адрес';
  PhraseRU61 = 'Транзакции';
  PhraseRU62 = 'Чтобы стать участником DAO, необходимо перевести 10 000 ORBC с личного счета ORBC';
  PhraseRU63 = 'Поздравляем, вы владелец ОМ';
  PhraseRU64 = 'Регистрация';
  PhraseRU65 = 'Не достаточно ORBC';
  PhraseRU66 = 'Создать токен';
  PhraseRU67 = 'Введите количество';
  PhraseRU68 = 'Введите адрес получателя';
  PhraseRU69 = 'Повторить пароль от криптоконтейнера';
  PhraseRU70 = 'Пароль от криптоконтейнера';
  PhraseRU71 = 'Вход';
  PhraseRU72 = 'Регистрация криптоконтейнера';
  PhraseRU73 = 'Выйти';
  PhraseRU74 = 'Сменить криптоконтейнер';
  PhraseRU75 = 'Ввести seed phrase';
  PhraseRU76 = 'Или';
  PhraseRU77 = 'Транзакция';
  PhraseRU78 = 'От';
  PhraseRU79 = 'Кому';
  PhraseRU80 = 'HASH';
  PhraseRU81 = 'Сумма';
  PhraseRU82 = 'Введите код';
  PhraseRU83 = '(Код введён не верно)';
  PhraseRU84 = 'Проверочный код';
  PhraseRU85 = 'Изменить пароль';
  PhraseRU86 = 'Начато скачивание обновления';
  PhraseRU87 = 'Распаковка обновления';
  PhraseRU88 = 'Установка обновления';
  PhraseRU89 = 'Соединение установлено';
  PhraseRU90 = 'Название токена';
  PhraseRU91 = 'Символ токена';
  PhraseRU92 = 'Разрядность: до 1*10  ';
  PhraseRU93 = '(до 8 знаков после запятой)';
  PhraseRU94 = 'Вы сохранили seed phrase?';
  PhraseRU95 = 'Введите seed phrase в поле ниже';
  PhraseRU96 = 'Seed phrase для восcтановления криптоконтейнера';
  PhraseRU97 = 'Скопируйте эту seed phrase и сохраните её';
  PhraseRU98 = 'Seed phrase не совпадает, проверьте её и повторите ещё раз';
  PhraseRU99 = 'Сделайте резервную копию криптоконтейнера прямо сейчас!';
  PhraseRU100 = 'На следующем шаге Вы увидите seed phrase, которая позволяет восстановить криптоконтейнер';
  PhraseRU101 = 'Я понимаю, что если я потеряю seed phrase, я потеряю доступ к своему криптоконтейнеру';
  PhraseRU102 = 'Seed phrase для восcтановления криптоконтейнера';
  PhraseRU103 = 'Скопируйте seed phrase и сохраните её';
  PhraseRU104 = 'Seed phrase является мастер-ключом к вашим средствам. Никогда не делитесь ей ни с кем другим.';
  PhraseRU105 = 'ORBIS никогда не попросит Вас поделиться своей seed phrase для восстановления.';
  PhraseRU106 = 'Если Вы потеряете seed phrase для восстановления, даже ORBIS не сможет вернуть Ваши средства';
  PhraseRU107 = 'Я понимаю риски';
  PhraseRU108 = 'Вы действительно хотите удалить выбранный криптоконтейнер?';
  PhraseRU109 = 'Неверный логин или пароль. Попробуйте снова.';
  PhraseRU110 = 'Адрес скопирован';
  PhraseRU111 = 'Количество должно быть больше нуля';
  PhraseRU112 = 'Некорректный адрес для перевода';
  PhraseRU113 = 'Инициализация обновления';
  PhraseRU114 = 'Восстановить криптоконтейнер';
  PhraseRU115 = 'Транзакции';
  PhraseRU116 = 'Успешная проверка протокола';
  PhraseRU117 = 'Успешная проверка версии';
  PhraseRU118 = 'Началась загрузка блоков';
  PhraseRU119 = 'Обработка загруженных блоков';
  PhraseRU120 = '(Минимальное значение 2)';
  PhraseRU121 = 'Пустое поле имени токена, заполните поле';
  PhraseRU122 = 'Пустое поле символа токена';
  PhraseRU123 = 'Токен должен быть взаимозаменяем';
  PhraseRU124 = 'Пустое поле разрядности';
  PhraseRU125 = 'Пустое поле количества токенов';
  PhraseRU126 =
    'Транзакция отправлена в сеть успешно. Ожидайте подтверждения транзакции. После подтверждения ваша транзакция появится в вашем списке транзакций. Если она не появилась в списке транзакций более 30 секунд, то сеть отклонила вашу транзакцию.';
  PhraseRU127 = 'Вы являетесь участником DAO.';
  PhraseRU128 =
    'Поздравляем, вы сгенерировали транзакцию на преобретение ОМ. Ожидайте подтверждение транзакции. После подтверждения ваша транзакция появится в вашем списке транзакций. Если она не появилась в'
    + ' списке транзакций более 30 секунд, то сеть отклонила вашу транзакцию.';
  PhraseRU129 = 'Несовпадение IP адреса конфигурации и действительного IP адреса.';
  PhraseRU130 = 'Извините. Вы не прошли авторизацию в сети валидаторов.';
  PhraseRU131 = 'Валидатор';
  PhraseRU132 = 'Валидатор';
  PhraseRU133 = 'Поздравляем, ваша транзакция отправлена в сеть. Ожидайте генерации ОМ.';
  PhraseRU134 = 'Извините, ваша транзакция не была завершена. Повторите попытку позже.';
  PhraseRU135 = 'Все';
  PhraseRU136 = 'Получено';
  PhraseRU137 = 'Отправлено';
  PhraseRU138 = 'Валюта';
  PhraseRU139 = 'Дата';
  PhraseRU140 = 'Поиск';
  PhraseRU141 = 'Хэш скопирован';
  PhraseRU142 = 'Транзакции не найдены';
  PhraseRU143 = 'Упорядочить по';
  PhraseRU144 = 'По убыванию';
  PhraseRU145 = 'По возрастанию';
  PhraseRU146 = 'Сортировать по';
  PhraseRU147 = 'Извините, на данный момент нет соединения, попробуйте позже';
  PhraseRU148 = 'Извините, на данный момент сеть еще не обработала ваш аккаунт, попробуйте позже';
  PhraseRU149 = '';

  { EN }
  PhraseEN1 = 'ORB MINING generation';
  PhraseEN2 = 'Quantity';
  PhraseEN3 = 'Confirm';
  PhraseEN4 = 'Cancel';
  PhraseEN5 = 'This operation will not be undone';
  PhraseEN6 = 'Translation';
  PhraseEN7 = 'To the address';
  PhraseEN8 = 'Commission';
  PhraseEN9 = 'Connection is established';
  PhraseEN10 = 'Create a password for the cryptocontainer';
  PhraseEN11 = 'Password';
  PhraseEN12 = 'Repeat password';
  PhraseEN13 = 'OK';
  PhraseEN14 = '(Password is too short)';
  PhraseEN15 = '(Passwords don''t match)';
  PhraseEN16 = 'Token bit rate';
  PhraseEN17 = 'The cost of the issue in ORBC';
  PhraseEN18 = 'Create a token';
  PhraseEN19 = 'Token transaction fee in the ORBIS network = 0 ORBC before the DAO decision is made';
  PhraseEN20 = 'Token Issue Volume';
  PhraseEN21 = 'Token symbol (no more than 4 uppercase Latin letters)';
  PhraseEN22 = 'Token name (any Latin letters)';
  PhraseEN23 = 'Enter seed phrase';
  PhraseEN24 = 'Seed phrase from a cryptocontainer';
  PhraseEN25 = 'Back';
  PhraseEN26 = '(Invalid seed phrase)';
  PhraseEN27 = 'Enter a new password for the cryptocontainer';
  PhraseEN28 = 'Cryptocontainer File';
  PhraseEN29 = 'Upload a cryptocontainer File';
  PhraseEN30 = 'Password from the cryptocontainer';
  PhraseEN31 = 'File selected';
  PhraseEN32 = 'Upload another file?';
  PhraseEN33 = '(Invalid password)';
  PhraseEN34 = 'Make a backup of your wallet right now';
  PhraseEN35 = 'In the next step, you will see a seed phrase that allows you to restore the wallet';
  PhraseEN36 = 'I understand that if I lose the seed phrase I will lose access to my wallet';
  PhraseEN37 = 'Continue';
  PhraseEN38 = 'Copy this seed phrase and save it';
  PhraseEN39 = 'Seed phrase to restore the cryptocontainer';
  PhraseEN40 = 'Next';
  PhraseEN41 = 'Log in';
  PhraseEN42 = 'Seed phrase is the master key to your funds. Never share it with anyone else.';
  PhraseEN43 = 'ORBIS will never ask you to share your seed phrase for recovery.';
  PhraseEN44 = 'If you lose the seed phrase for recovery, even ORBIS will not be able to return your funds.';
  PhraseEN45 = 'I understand the risks';
  PhraseEN46 = 'Log in';
  PhraseEN47 = 'Registration';
  PhraseEN48 = 'Password from the cryptocontainer';
  PhraseEN49 = 'Cryptocontainer';
  PhraseEN50 = 'Enter seed phrase';
  PhraseEN51 = 'Delete the cryptocontainer';
  PhraseEN52 = 'My address';
  PhraseEN53 = 'Copy Address';
  PhraseEN54 = 'Download QR';
  PhraseEN55 = 'Address copied';
  PhraseEN56 = 'Send';
  PhraseEN57 = 'Coin/Token:';
  PhraseEN58 = 'Balance';
  PhraseEN60 = 'Address';
  PhraseEN61 = 'Transactions';
  PhraseEN62 = 'To become a DAO member, you need to transfer 10,000 ORBC from your personal ORBC account';
  PhraseEN63 = 'Congratulations, you are the owner of OM';
  PhraseEN64 = 'Registration';
  PhraseEN65 = 'Not enough ORBC';
  PhraseEN66 = 'Create   Token';
  PhraseEN67 = 'Enter the quantity';
  PhraseEN68 = 'Enter the recipient''s address';
  PhraseEN69 = 'Repeat the password from the cryptocontainer';
  PhraseEN70 = 'Password from the cryptocontainer';
  PhraseEN71 = 'Log in';
  PhraseEN72 = 'Registration of a cryptocontainer';
  PhraseEN73 = 'Exit';
  PhraseEN74 = 'Change the cryptocontainer';
  PhraseEN75 = 'Enter seed phrase';
  PhraseEN76 = 'Or';
  PhraseEN77 = 'Transaction';
  PhraseEN78 = 'From';
  PhraseEN79 = 'To whom';
  PhraseEN80 = 'HASH';
  PhraseEN81 = 'Amount';
  PhraseEN82 = 'Enter the code';
  PhraseEN83 = '(Code entered incorrectly)';
  PhraseEN84 = 'Verification code';
  PhraseEN85 = 'Change password';
  PhraseEN86 = 'Start downloading update';
  PhraseEN87 = 'Unpacking update';
  PhraseEN88 = 'Installation update';
  PhraseEN89 = 'Connection established';
  PhraseEN90 = 'Token name';
  PhraseEN91 = 'Token symbol';
  PhraseEN92 = 'Bit depth: up to 1*10';
  PhraseEN93 = '(up to 8 decimal places)';
  PhraseEN94 = 'Have you saved the seed phrase?';
  PhraseEN95 = 'Enter seed phrase in the box below';
  PhraseEN96 = 'Seed phrase for restoring a cryptocontainer';
  PhraseEN97 = 'Copy this seed phrase and save it';
  PhraseEN98 = 'Seed phrase does not match, check it and repeat again';
  PhraseEN99 = 'Back up your cryptocontainer now!';
  PhraseEN100 = 'In the next step, you will see a seed phrase that allows you to restore the cryptocontainer';
  PhraseEN101 = 'I understand that if I lose my seed phrase, I will lose access to my cryptocontainer';
  PhraseEN102 = 'Seed phrase for restoring a cryptocontainer';
  PhraseEN103 = 'Copy the seed phrase and save it';
  PhraseEN104 = 'Seed phrase is the master key to your funds. Never share it with anyone else.';
  PhraseEN105 = 'ORBIS will never ask you to share your seed phrase for recovery.';
  PhraseEN106 = 'If you lose your seed phrase for recovery, even ORBIS will not be able to recover your funds.';
  PhraseEN107 = 'I understand the risks';
  PhraseEN108 = 'Are you sure you want to delete the selected cryptocontainer?';
  PhraseEN109 = 'Bad Login or Password. Try Again.';
  PhraseEN110 = 'Address copied';
  PhraseEN111 = 'The quantity must be greater than zero';
  PhraseEN112 = 'Invalid translation address';
  PhraseEN113 = 'Initializing update';
  PhraseEN114 = 'Restore cryptocontainer';
  PhraseEN115 = 'Transactions';
  PhraseEN116 = 'Successful protocol check';
  PhraseEN117 = 'Successful version check';
  PhraseEN118 = 'Blocks loading started';
  PhraseEN119 = 'Processing loaded blocks';
  PhraseEN120 = '(Min value 2)';
  PhraseEN121 = 'Blank token name field, fill in the field';
  PhraseEN122 = 'Empty token symbol field';
  PhraseEN123 = 'The token must be fungible';
  PhraseEN124 = 'Empty bit field';
  PhraseEN125 = 'Empty field for the number of tokens';
  PhraseEN126 =
    'The transaction was successfully sent to the network. Wait for transaction confirmation. After confirmation, your transaction will be added to the list of'
    + ' transactions. If it does not appear in the list of transactions for more than 30 seconds, then the network has rejected your transaction.';
  PhraseEN127 = 'You are a DAO member.';
  PhraseEN128 =
    'Congratulations, you have generated a transaction to purchase an OM. Wait for transaction confirmation. After confirmation, your transaction will be added to the list of transactions. If it does not appear in the'
    + ' list of transactions for more than 30 seconds, then the network has rejected your transaction.';
  PhraseEN129 = 'Mismatch between the configuration IP address and the actual IP address.';
  PhraseEN130 = 'Sorry. You are not logged into the validator network.';
  PhraseEN131 = 'Validator';
  PhraseEN132 = 'Validator';
  PhraseEN133 = 'Congratulations, your transaction has been sent to the network. Expect OM generation.';
  PhraseEN134 = 'Sorry, your transaction was not completed, please try again later.';
  PhraseEN135 = 'All';
  PhraseEN136 = 'Incoming';
  PhraseEN137 = 'Outgoing';
  PhraseEN138 = 'Currency';
  PhraseEN139 = 'Date';
  PhraseEN140 = 'Search';
  PhraseEN141 = 'Hash copied';
  PhraseEN142 = 'Transactions not found';
  PhraseEN143 = 'Sort by';
  PhraseEN144 = 'Descending';
  PhraseEN145 = 'Ascending';
  PhraseEN146 = 'Order by';
  PhraseEN147 = 'Sorry, no connection at the moment, please try again later';
  PhraseEN148 = 'Sorry, the network has not yet processed your account, please try again later';
  PhraseEN149 = 'Order by';

type
  TTranslateCore = class
  public
    class function GetPhrase(ACode: integer; ALanguage: TLanguages): string; static; stdcall;
  end;

implementation

{ TTranslateCore }

class function TTranslateCore.GetPhrase(ACode: integer; ALanguage: TLanguages): string;
begin
  case ALanguage of
    Russian:
      begin
        case ACode of
          Index1:
            Result := PhraseRU1;
          Index2:
            Result := PhraseRU2;
          Index3:
            Result := PhraseRU3;
          Index4:
            Result := PhraseRU4;
          Index5:
            Result := PhraseRU5;
          Index6:
            Result := PhraseRU6;
          Index7:
            Result := PhraseRU7;
          Index8:
            Result := PhraseRU8;
          Index9:
            Result := PhraseRU9;
          Index10:
            Result := PhraseRU10;
          Index11:
            Result := PhraseRU11;
          Index12:
            Result := PhraseRU12;
          Index13:
            Result := PhraseRU13;
          Index14:
            Result := PhraseRU14;
          Index15:
            Result := PhraseRU15;
          Index16:
            Result := PhraseRU16;
          Index17:
            Result := PhraseRU17;
          Index18:
            Result := PhraseRU18;
          Index19:
            Result := PhraseRU19;
          Index20:
            Result := PhraseRU20;
          Index21:
            Result := PhraseRU21;
          Index22:
            Result := PhraseRU22;
          Index23:
            Result := PhraseRU23;

          Index24:

            Result := PhraseRU24;

          Index25:

            Result := PhraseRU25;

          Index26:

            Result := PhraseRU26;

          Index27:

            Result := PhraseRU27;

          Index28:

            Result := PhraseRU28;

          Index29:

            Result := PhraseRU29;

          Index30:

            Result := PhraseRU30;

          Index31:

            Result := PhraseRU31;

          Index32:

            Result := PhraseRU32;

          Index33:

            Result := PhraseRU33;

          Index34:

            Result := PhraseRU34;

          Index35:

            Result := PhraseRU35;

          Index36:

            Result := PhraseRU36;

          Index37:

            Result := PhraseRU37;

          Index38:

            Result := PhraseRU38;

          Index39:

            Result := PhraseRU39;

          Index40:

            Result := PhraseRU40;

          Index41:

            Result := PhraseRU41;

          Index42:

            Result := PhraseRU42;

          Index43:

            Result := PhraseRU43;

          Index44:

            Result := PhraseRU44;

          Index45:

            Result := PhraseRU45;

          Index46:

            Result := PhraseRU46;

          Index47:

            Result := PhraseRU47;

          Index48:

            Result := PhraseRU48;

          Index49:

            Result := PhraseRU49;

          Index50:

            Result := PhraseRU50;

          Index51:

            Result := PhraseRU51;

          Index52:

            Result := PhraseRU52;

          Index53:

            Result := PhraseRU53;

          Index54:

            Result := PhraseRU54;

          Index55:

            Result := PhraseRU55;

          Index56:

            Result := PhraseRU56;

          Index57:

            Result := PhraseRU57;

          Index58:

            Result := PhraseRU58;

          Index60:

            Result := PhraseRU60;

          Index61:

            Result := PhraseRU61;

          Index62:

            Result := PhraseRU62;

          Index63:

            Result := PhraseRU63;

          Index64:

            Result := PhraseRU64;

          Index65:

            Result := PhraseRU65;

          Index66:

            Result := PhraseRU66;

          Index67:

            Result := PhraseRU67;

          Index68:

            Result := PhraseRU68;

          Index69:

            Result := PhraseRU69;

          Index70:

            Result := PhraseRU70;

          Index71:

            Result := PhraseRU71;

          Index72:

            Result := PhraseRU72;

          Index73:

            Result := PhraseRU73;

          Index74:

            Result := PhraseRU74;

          Index75:

            Result := PhraseRU75;

          Index76:

            Result := PhraseRU76;

          Index77:

            Result := PhraseRU77;

          Index78:

            Result := PhraseRU78;

          Index79:

            Result := PhraseRU79;

          Index80:

            Result := PhraseRU80;

          Index81:

            Result := PhraseRU81;

          Index82:

            Result := PhraseRU82;

          Index83:

            Result := PhraseRU83;

          Index84:

            Result := PhraseRU84;

          Index85:

            Result := PhraseRU85;

          Index86:

            Result := PhraseRU86;

          Index87:

            Result := PhraseRU87;

          Index88:

            Result := PhraseRU88;

          Index89:

            Result := PhraseRU89;
          Index90:

            Result := PhraseRU90;
          Index91:
            Result := PhraseRU91;
          Index92:
            Result := PhraseRU92;
          Index93:
            Result := PhraseRU93;
          Index94:
            begin
              Result := PhraseRU94;
            end;
          Index95:
            begin
              Result := PhraseRU95;
            end;
          Index96:
            begin
              Result := PhraseRU96;
            end;
          Index97:
            begin
              Result := PhraseRU97;
            end;
          Index98:
            begin
              Result := PhraseRU98;
            end;
          Index99:
            begin
              Result := PhraseRU99;
            end;
          Index100:
            begin
              Result := PhraseRU100;
            end;
          Index101:
            begin
              Result := PhraseRU101;
            end;
          Index102:
            begin
              Result := PhraseRU102;
            end;
          Index103:
            begin
              Result := PhraseRU103;
            end;
          Index104:
            begin
              Result := PhraseRU104;
            end;
          Index105:
            begin
              Result := PhraseRU105;
            end;
          Index106:
            begin
              Result := PhraseRU106;
            end;
          Index107:
            begin
              Result := PhraseRU107;
            end;
          Index108:
            begin
              Result := PhraseRU108;
            end;
          Index109:
            begin
              Result := PhraseRU109;
            end;
          Index110:
            begin
              Result := PhraseRU110;
            end;
          Index111:
            begin
              Result := PhraseRU111;
            end;
          Index112:
            begin
              Result := PhraseRU112;
            end;
          Index113:
            begin
              Result := PhraseRU113;
            end;
          Index114:
            begin
              Result := PhraseRU114;
            end;
          Index115:
            begin
              Result := PhraseRU115;
            end;
          Index116:
            begin
              Result := PhraseRU116;
            end;
          Index117:
            begin
              Result := PhraseRU117;
            end;
          Index118:
            begin
              Result := PhraseRU118;
            end;
          Index119:
            begin
              Result := PhraseRU119;
            end;
          Index120:
            begin
              Result := PhraseRU120;
            end;
          Index121:
            begin
              Result := PhraseRU121;
            end;
          Index122:
            begin
              Result := PhraseRU122;
            end;
          Index123:
            begin
              Result := PhraseRU123;
            end;
          Index124:
            begin
              Result := PhraseRU124;
            end;
          Index125:
            begin
              Result := PhraseRU125;
            end;
          Index126:
            begin
              Result := PhraseRU126;
            end;
          Index127:
            begin
              Result := PhraseRU127;
            end;
          Index128:
            begin
              Result := PhraseRU128;
            end;
          Index129:
            begin
              Result := PhraseRU129;
            end;
          Index130:
            begin
              Result := PhraseRU130;
            end;
          Index131:
            begin
              Result := PhraseRU131;
            end;
          Index132:
            begin
              Result := PhraseRU132;
            end;
          Index133:
            begin
              Result := PhraseRU133;
            end;
          Index134:
            begin
              Result := PhraseRU134;
            end;
          Index135:
            begin
              Result := PhraseRU135;
            end;
          Index136:
            begin
              Result := PhraseRU136;
            end;
          Index137:
            begin
              Result := PhraseRU137;
            end;
          Index138:
            begin
              Result := PhraseRU138;
            end;
          Index139:
            begin
              Result := PhraseRU139;
            end;
          Index140:
            begin
              Result := PhraseRU140;
            end;
          Index141:
            begin
              Result := PhraseRU141;
            end;
          Index142:
            begin
              Result := PhraseRU142;
            end;
          Index143:
            begin
              Result := PhraseRU143;
            end;
          Index144:
            begin
              Result := PhraseRU144;
            end;
          Index145:
            begin
              Result := PhraseRU145;
            end;
          Index146:
            begin
              Result := PhraseRU146;
            end;
          Index147:
            begin
              Result := PhraseRU147;
            end;
          Index148:
            begin
              Result := PhraseRU148;
            end;

        end;
      end;
    English:
      begin
        case ACode of
          Index1:
            begin
              Result := PhraseEN1;
            end;
          Index2:
            begin
              Result := PhraseEN2;
            end;
          Index3:
            begin
              Result := PhraseEN3;
            end;
          Index4:
            begin
              Result := PhraseEN4;
            end;
          Index5:
            begin
              Result := PhraseEN5;
            end;
          Index6:
            begin
              Result := PhraseEN6;
            end;
          Index7:
            begin
              Result := PhraseEN7;
            end;
          Index8:
            begin
              Result := PhraseEN8;
            end;
          Index9:
            begin
              Result := PhraseEN9;
            end;
          Index10:
            begin
              Result := PhraseEN10;
            end;
          Index11:
            begin
              Result := PhraseEN11;
            end;
          Index12:
            begin
              Result := PhraseEN12;
            end;
          Index13:
            begin
              Result := PhraseEN13;
            end;
          Index14:
            begin
              Result := PhraseEN14;
            end;
          Index15:
            begin
              Result := PhraseEN15;
            end;
          Index16:
            begin
              Result := PhraseEN16;
            end;
          Index17:
            begin
              Result := PhraseEN17;
            end;
          Index18:
            begin
              Result := PhraseEN18;
            end;
          Index19:
            begin
              Result := PhraseEN19;
            end;
          Index20:
            begin
              Result := PhraseEN20;
            end;
          Index21:
            begin
              Result := PhraseEN21;
            end;
          Index22:
            begin
              Result := PhraseEN22;
            end;
          Index23:
            begin
              Result := PhraseEN23;
            end;
          Index24:
            begin
              Result := PhraseEN24;
            end;
          Index25:
            begin
              Result := PhraseEN25;
            end;
          Index26:
            begin
              Result := PhraseEN26;
            end;
          Index27:
            begin
              Result := PhraseEN27;
            end;
          Index28:
            begin
              Result := PhraseEN28;
            end;
          Index29:
            begin
              Result := PhraseEN29;
            end;
          Index30:
            begin
              Result := PhraseEN30;
            end;
          Index31:
            begin
              Result := PhraseEN31;
            end;
          Index32:
            begin
              Result := PhraseEN32;
            end;
          Index33:
            begin
              Result := PhraseEN33;
            end;
          Index34:
            begin
              Result := PhraseEN34;
            end;
          Index35:
            begin
              Result := PhraseEN35;
            end;
          Index36:
            begin
              Result := PhraseEN36;
            end;
          Index37:
            begin
              Result := PhraseEN37;
            end;
          Index38:
            begin
              Result := PhraseEN38;
            end;
          Index39:
            begin
              Result := PhraseEN39;
            end;
          Index40:
            begin
              Result := PhraseEN40;
            end;
          Index41:
            begin
              Result := PhraseEN41;
            end;
          Index42:
            begin
              Result := PhraseEN42;
            end;
          Index43:
            begin
              Result := PhraseEN43;
            end;
          Index44:
            begin
              Result := PhraseEN44;
            end;
          Index45:
            begin
              Result := PhraseEN45;
            end;
          Index46:
            begin
              Result := PhraseEN46;
            end;
          Index47:
            begin
              Result := PhraseEN47;
            end;
          Index48:
            begin
              Result := PhraseEN48;
            end;
          Index49:
            begin
              Result := PhraseEN49;
            end;
          Index50:
            begin
              Result := PhraseEN50;
            end;
          Index51:
            begin
              Result := PhraseEN51;
            end;
          Index52:
            begin
              Result := PhraseEN52;
            end;
          Index53:
            begin
              Result := PhraseEN53;
            end;
          Index54:
            begin
              Result := PhraseEN54;
            end;
          Index55:
            begin
              Result := PhraseEN55;
            end;
          Index56:
            begin
              Result := PhraseEN56;
            end;
          Index57:
            begin
              Result := PhraseEN57;
            end;
          Index58:
            begin
              Result := PhraseEN58;
            end;
          Index60:
            begin
              Result := PhraseEN60;
            end;
          Index61:
            begin
              Result := PhraseEN61;
            end;
          Index62:
            begin
              Result := PhraseEN62;
            end;
          Index63:
            begin
              Result := PhraseEN63;
            end;
          Index64:
            begin
              Result := PhraseEN64;
            end;
          Index65:
            begin
              Result := PhraseEN65;
            end;
          Index66:
            begin
              Result := PhraseEN66;
            end;
          Index67:
            begin
              Result := PhraseEN67;
            end;
          Index68:
            begin
              Result := PhraseEN68;
            end;
          Index69:
            begin
              Result := PhraseEN69;
            end;
          Index70:
            begin
              Result := PhraseEN70;
            end;
          Index71:
            begin
              Result := PhraseEN71;
            end;
          Index72:
            begin
              Result := PhraseEN72;
            end;
          Index73:
            begin
              Result := PhraseEN73;
            end;
          Index74:
            begin
              Result := PhraseEN74;
            end;
          Index75:
            begin
              Result := PhraseEN75;
            end;
          Index76:
            begin
              Result := PhraseEN76;
            end;
          Index77:
            begin
              Result := PhraseEN77;
            end;
          Index78:
            begin
              Result := PhraseEN78;
            end;
          Index79:
            begin
              Result := PhraseEN79;
            end;
          Index80:
            begin
              Result := PhraseEN80;
            end;
          Index81:
            begin
              Result := PhraseEN81;
            end;
          Index82:
            begin
              Result := PhraseEN82;
            end;
          Index83:
            begin
              Result := PhraseEN83;
            end;
          Index84:
            begin
              Result := PhraseEN84;
            end;
          Index85:
            begin
              Result := PhraseEN85;
            end;
          Index86:
            begin
              Result := PhraseEN86;
            end;
          Index87:
            begin
              Result := PhraseEN87;
            end;
          Index88:
            begin
              Result := PhraseEN88;
            end;
          Index89:
            begin
              Result := PhraseEN89;
            end;
          Index90:
            begin
              Result := PhraseEN90;
            end;
          Index91:
            begin
              Result := PhraseEN91;
            end;
          Index92:
            begin
              Result := PhraseEN92;
            end;
          Index93:
            begin
              Result := PhraseEN93;
            end;
          Index94:
            begin
              Result := PhraseEN94;
            end;
          Index95:
            begin
              Result := PhraseEN95;
            end;
          Index96:
            begin
              Result := PhraseEN96;
            end;
          Index97:
            begin
              Result := PhraseEN97;
            end;
          Index98:
            begin
              Result := PhraseEN98;
            end;
          Index99:
            begin
              Result := PhraseEN99;
            end;
          Index100:
            begin
              Result := PhraseEN100;
            end;
          Index101:
            begin
              Result := PhraseEN101;
            end;
          Index102:
            begin
              Result := PhraseEN102;
            end;
          Index103:
            begin
              Result := PhraseEN103;
            end;
          Index104:
            begin
              Result := PhraseEN104;
            end;
          Index105:
            begin
              Result := PhraseEN105;
            end;
          Index106:
            begin
              Result := PhraseEN106;
            end;
          Index107:
            begin
              Result := PhraseEN107;
            end;
          Index108:
            begin
              Result := PhraseEN108;
            end;
          Index109:
            begin
              Result := PhraseEN109;
            end;
          Index110:
            begin
              Result := PhraseEN110;
            end;
          Index111:
            begin
              Result := PhraseEN111;
            end;
          Index112:
            begin
              Result := PhraseEN112;
            end;
          Index113:
            begin
              Result := PhraseEN113;
            end;
          Index114:
            begin
              Result := PhraseEN114;
            end;
          Index115:
            begin
              Result := PhraseEN115;
            end;
          Index116:
            begin
              Result := PhraseEN116;
            end;
          Index117:
            begin
              Result := PhraseEN117;
            end;
          Index118:
            begin
              Result := PhraseEN118;
            end;
          Index119:
            begin
              Result := PhraseEN119;
            end;
          Index120:
            begin
              Result := PhraseEN120;
            end;
          Index121:
            begin
              Result := PhraseEN121;
            end;
          Index122:
            begin
              Result := PhraseEN122;
            end;
          Index123:
            begin
              Result := PhraseEN123;
            end;
          Index124:
            begin
              Result := PhraseEN124;
            end;
          Index125:
            begin
              Result := PhraseEN125;
            end;
          Index126:
            begin
              Result := PhraseEN126;
            end;
          Index127:
            begin
              Result := PhraseEN127;
            end;
          Index128:
            begin
              Result := PhraseEN128;
            end;
          Index129:
            begin
              Result := PhraseEN129;
            end;
          Index130:
            begin
              Result := PhraseEN130;
            end;
          Index131:
            begin
              Result := PhraseEN131;
            end;
          Index132:
            begin
              Result := PhraseEN132;
            end;
          Index133:
            begin
              Result := PhraseEN133;
            end;
          Index134:
            begin
              Result := PhraseEN134;
            end;
          Index135:
            begin
              Result := PhraseEN135;
            end;
          Index136:
            begin
              Result := PhraseEN136;
            end;
          Index137:
            begin
              Result := PhraseEN137;
            end;
          Index138:
            begin
              Result := PhraseEN138;
            end;
          Index139:
            begin
              Result := PhraseEN139;
            end;
          Index140:
            begin
              Result := PhraseEN140;
            end;
          Index141:
            begin
              Result := PhraseEN141;
            end;
          Index142:
            begin
              Result := PhraseEN142;
            end;
          Index143:
            begin
              Result := PhraseEN143;
            end;
          Index144:
            begin
              Result := PhraseEN144;
            end;
          Index145:
            begin
              Result := PhraseEN145;
            end;
          Index146:
            begin
              Result := PhraseEN146;
            end;
          Index147:
            begin
              Result := PhraseEN147;
            end;
          Index148:
            begin
              Result := PhraseEN148;
            end;

        end;
      end;
  end;
end;

end.

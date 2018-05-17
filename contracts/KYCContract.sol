pragma solidity ^0.4.23;

/**
 * @title KYCContract
 * @notice KYC 用のコントラクト
 */
contract KYCContract {
  address owner;

  // @notice 閲覧許可情報
  struct AppDetail {
    bool allowReference;
    uint256 approveBlockNo;
    uint256 refLimitBlockNo;
    address applicant;
  }

  /**
   * @notice 本人確認情報
   * name: 名前
   * birth: 誕生日
   * email: メールアドレス
   * addr: 住所
   * tel: 電話番号
   */
  struct PersonDetail {
    string name;
    string birth;
    string email;
    string addr; // @notice address が予約後なので addr
    string tel;
  }

  // @notice アドレスがキーの閲覧許可情報
  mapping(address => AppDetail) appDetail;

  // @notice アドレスがキーの本人確認情報
  mapping(address => PersonDetail) personDetail;

  // @notice コンストラクタ
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @notice set
   */
  // @notice 本人情報を登録する
  function setPerson(string _name, string _birth, string _email, string _addr, string _tel) public {
    personDetail[msg.sender].name = _name;
    personDetail[msg.sender].birth = _birth;
    personDetail[msg.sender].email = _email;
    personDetail[msg.sender].addr = _addr;
    personDetail[msg.sender].tel = _tel;
  }

  // @notice 閲覧許可・期間の設定
  // @dev 指定した block.number 分だけ閲覧許可を出す
  function setApprove(address _applicant, uint256 _span) public {
    appDetail[msg.sender].allowReference = true;
    appDetail[msg.sender].approveBlockNo = block.number;
    appDetail[msg.sender].refLimitBlockNo = block.number + _span;
    appDetail[msg.sender].applicant = _applicant;
  }

  // @notice 緊急時、閲覧を停止させる
  function setDisallowReference() public {
    appDetail[msg.sender].allowReference = false;
  }

  /**
   * @notice get
   */
  // @notice 本人確認情報を参照する
  // @dev personDetail を struct で return したかったけど、 `This type is only supported in the new experimental ABI encoder.` だったのでバラバラで出力…
  function getPerson(address _person) public constant returns (
    bool _allowReference,
    uint256 _approveBlockNo,
    uint256 _refLimitBlockNo,
    address _applicant,
    string _name,
    string _birth,
    string _email,
    string _addr,
    string _tel
  ) {
    // @notice 閲覧許可情報
    // owner と 本人はいつでも見れる
    _allowReference = appDetail[_person].allowReference;
    _approveBlockNo = appDetail[_person].approveBlockNo;
    _refLimitBlockNo = appDetail[_person].refLimitBlockNo;
    _applicant = appDetail[_person].applicant;
    // @notice 閲覧を制限する本人情報
    if (((msg.sender == _applicant)
      && (_allowReference == true)
      && (block.number < _refLimitBlockNo))
      || (msg.sender == owner)
      || (msg.sender == _person)) {
      _name = personDetail[_person].name;
      _birth = personDetail[_person].birth;
      _email = personDetail[_person].email;
      _addr = personDetail[_person].addr;
      _tel = personDetail[_person].tel;
    }
  }
}

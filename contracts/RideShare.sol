// SPDX-License-Identifier: Unlicense

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity >=0.8.4;


contract RideShare is ERC20{
    
    // Used to store Coordinates of a location
    struct Coordinates{
        int256 lat;
        int256 long;
    }

//information about the drivers
    struct driver{
        uint256 licenseNumber;
        uint256 vehicleNumber;
        uint256 phoneNumber;
        address driverAddr;
        bool isApproved;
    }

//Information about passengers
    struct Rider{
        address riderAddr;
        uint256 phoneNumber;
    }   

    struct Rides{
        uint256 rideId;
        address riderAddr;
        address driverAddr;
        Coordinates pickup;
        Coordinates dropoff;
        bool Paired;
        uint256 fare;
        uint256 arrivalTime;
        bool driverArrived;
        bool customerPicked;
        bool inProgress;
        bool paid;
    }

    address[] public driverList;
    address[] public riderslist;

    Rides[] public RideReq;
    address public  owner;

    uint256 cap = 1000000000 * 10**18;


    mapping(address=>driver) drivers;
    mapping(address=>Rider) riders;
    mapping(address=>bool) isDriver;
    mapping(address=>bool) isRider;


    mapping(uint256=>mapping(uint256=>bool)) Registered;
    uint256 [] public registeredDriverList;

    constructor ()
        ERC20("RideSharing", "RIDE")
    {
        owner = msg.sender;
    }

    function mint(address account) public payable {
        require(msg.value>0,"Provide eth to get RIDE Tokens");

        uint256 amount = msg.value*223100;
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(super.totalSupply() + amount <= cap, "cap exceeded");
        super._mint(account, amount);
    }


    function addDriver(uint256 vehicle, uint256 license, uint256 phone) public {
        require(!isDriver[msg.sender],"Already Registered");
        require(msg.sender != owner,"Contract owner cannot register as driver");
         
        address _addr = msg.sender;
        driverList.push(_addr);

        isDriver[_addr]=true;
        drivers[_addr].vehicleNumber = vehicle;
        drivers[_addr].licenseNumber =license;
        drivers[_addr].phoneNumber = phone;
        drivers[_addr].driverAddr =_addr; 
        drivers[_addr].isApproved = false;
        
        if (Registered[vehicle][license] == true){
            drivers[_addr].isApproved = true;
        }
    }

    function joinAsRider(uint256 phoneNumber) public{
        require(!isRider[msg.sender],"Already Registered");
        address _addr = msg.sender;
        riders[_addr].riderAddr = _addr;
        riders[_addr].phoneNumber = phoneNumber;

        isRider[_addr] = true;
        riderslist.push(_addr);
    }

    //Register the doctor by certain authority
    function registerDriver(uint256 vehicle, uint256 license) public {
        require(msg.sender==owner,"You are not allowed to register doctor!");
        Registered[vehicle][license] = true;
        registeredDriverList.push(license);
    
    }

    function requestRide(int256[] memory pick, int256[] memory drop, uint256 amount) public {
        require(isRider[msg.sender],"Register before using");

        transfer(address(this),amount);
        Rides memory rides;
        rides.rideId = RideReq.length;
        rides.riderAddr = msg.sender;
        rides.driverAddr = address(0);
        rides.pickup = Coordinates({lat: pick[0], long: pick[1]});
        rides.dropoff = Coordinates({lat: drop[0], long: drop[1]});
        rides.fare = amount;
        rides.arrivalTime = 0;
        rides.customerPicked = false;
        rides.driverArrived = false;
        rides.inProgress = false;
        rides.paid = false;

        RideReq.push(rides);     

    }


    function getWaitingRiders() public view returns(Rider memory riderdetails, Coordinates memory pick, Coordinates memory drop, uint256 price) {
    // returns list of waiting riders to a driver
    for (uint i=0; i<RideReq.length; i++) {
        if (RideReq[i].driverAddr == address(0)){
            return(riders[RideReq[i].riderAddr],RideReq[i].pickup, RideReq[i].dropoff, RideReq[i].fare);
        }
        }
    }

    function selectRider(uint256 rideId, uint256 arrivalTime) public{
        require(isDriver[msg.sender], " Only Driver has the authority");
        require(RideReq[rideId].driverAddr == address(0), "driver currently paired");

        RideReq[rideId].driverAddr = msg.sender;
        RideReq[rideId].arrivalTime = arrivalTime;
        RideReq[rideId].driverArrived = false;
    }

    function getDriverDetails(address driverAddr) public view returns(driver memory details){
        return drivers[driverAddr];
    }

    function payDriver(uint256 rideId) public {
        // rider pays driver fixed amount for amount of trip complete
        require(RideReq[rideId].driverAddr != address(0), "Rider needs to have an assigned driver to pay");
        require(!RideReq[rideId].paid , "Hasn't paid earlier");
        IERC20 token = IERC20(address(this));
        uint256 amount = RideReq[rideId].fare;
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        token.transfer(RideReq[rideId].driverAddr, amount);
        RideReq[rideId].paid = true;
    }   
}
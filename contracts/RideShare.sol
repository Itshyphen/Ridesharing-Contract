// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

contract RideShare{
    
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
        Coordinates pickup;
        Coordinates dropoff;
    }   

    struct Ride{
        address riderAddr;
        address driverAddr;
        Coordinates pickup;
        Coordinates dropoff;
        bool Paired;
        uint256 fare;
        uint256 arrivalTime;
        bool driverArrived;
        bool inProgress;
        bool paid;
    }
    
    struct RideStatus{
        mapping(address=>address) pairing;//pairing[rider]=driver
        uint256 arrivalTime;
        bool driverArrived;
        bool inProgress;
        bool paid;
    }
       

    address[] public driverList;
    address[] public riderslist;

    Ride[] public RideReq;
    address public  owner;

    mapping(address=>driver) drivers;
    mapping(address=>Rider) riders;
    mapping(address=>bool) isDriver;
    mapping(address=>bool) isRider;


    mapping(uint256=>mapping(uint256=>bool)) Registered;
    uint256 [] public registeredDoctorList;



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

    //Register the doctor by certain authority
    function registerDriver(uint256 vehicle, uint256 license) public {
        require(msg.sender==owner,"You are not allowed to register doctor!");
        Registered[vehicle][license] = true;
        registeredDoctorList.push(license);
    
    }

    function requestRide(int256[] memory pick, int256[] memory drop, uint256 price) public {
        require(isRider[msg.sender],"Register before using");

        Ride memory rides;
        rides.riderAddr = msg.sender;
        rides.driverAddr = address(0);
        rides.pickup = Coordinates({lat: pick[0], long: pick[1]});
        rides.dropoff = Coordinates({lat: drop[0], long: drop[1]});
        rides.fare = price;
        rides.arrivalTime = 0;
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

    function selectRider(uint riderNumber, uint arrivalTime) public{

    }

 

    
}
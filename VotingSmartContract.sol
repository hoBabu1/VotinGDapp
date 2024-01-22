//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract VotingSmartContract
{
    struct Voter{
        string name ;
        uint age ;
        string gender;
        uint voterId;
        uint voteCandidateId;
        address voterAddress;
    }
    struct Candidate{
        string name ;
        uint age ;
        string gender;
        uint candidateId;
        string party ;
        uint votes ;
        address candidtaeAddress;
    }
    address electionCommission;
    address winner ;

    uint nextVoterId =1;
    uint nextCandidateId =1;

    uint startTime; // start time of election 
    uint endTime;    // end time of election 

    mapping(uint => Voter) voterDetails;
    mapping(uint=> Candidate) candidateDetails;
    bool stopVoting ;
    constructor ()
    {
        electionCommission = msg.sender ;
        
    }
    modifier isVotingOver()
    {
        require(stopVoting == false && endTime>block.timestamp , "Voitng is Over");
        _;
    }
    modifier onlyElectionCommission()
    {
        require(msg.sender == electionCommission , "You are not an Election Commissioner");
        _;
    }
    function candidateRegister(string calldata _name , 
                               string calldata _party ,
                               uint _age ,
                               string calldata _gender) external
    {
        require(_age>18 , "You are under age babu");
        require(candidateVerification(msg.sender), "Dubara se registrartion nahi babu ");
        require(nextCandidateId < 3 ,"candidate registration is full");
        candidateDetails[nextCandidateId]=  Candidate({
            name:_name,
            party:_party,
            age:_age,
            gender:_gender,
            votes:0,
            candidtaeAddress:msg.sender,
            candidateId:nextCandidateId
        });
        nextCandidateId++;
    }
    function candidateVerification(address _person ) internal view returns(bool){
        for(uint i = 1 ; i<nextCandidateId ; i++)
        {
            if(candidateDetails[i].candidtaeAddress == _person)
            {
                return false ;
            }
        }
        return true ;
    }
    function candidateList() public view returns(Candidate[] memory)
    {
        Candidate[] memory candidateArray = new Candidate[](nextCandidateId-1)  ;
        for(uint i = 1 ; i<nextCandidateId ; i++)
        {
           candidateArray[i-1] = candidateDetails[i];
        }
        return candidateArray ;
    }
    function VoterRegister(string calldata _name,uint _age ,string calldata _gender) external
    {
        require(_age>=18 , "You are cute baccha ");
        require(candidateVerification(msg.sender) , "you already Exists");
        voterDetails[nextVoterId++] = Voter({name:_name , age :_age , gender:_gender ,voterId:nextVoterId , voteCandidateId:0 , voterAddress:msg.sender });
    }
    function voterVerification(address _person) internal view returns(bool)
    {
        for(uint i = 1 ; i<nextVoterId ; i++)
        {
            if(_person == voterDetails[i].voterAddress)
            return false ;
        }
        return true ;
    }
    function voterList() public view returns(Voter[] memory)
    {
        Voter[] memory voterArr = new Voter[](nextVoterId-1);
        for(uint i = 1 ; i<nextVoterId ; i++)
        {
            voterArr[i-1] = voterDetails[i];
        }
        return voterArr;
    }
    function vote(uint _voterId , uint _candidateId) external isVotingOver()
    {
        require(voterDetails[_voterId].voterAddress == msg.sender , "You have not registered ");
        require(_candidateId>0 && _candidateId<nextCandidateId , "Cndidate id is not valid "  );
        require(voterDetails[_voterId].voteCandidateId == 0 , "You have already Voted ");
        require(nextCandidateId>2 , "there is only one candidate ");
        require(startTime>0 , "Voting is not staerted");
        voterDetails[_voterId].voteCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;

    }
    function voteTime(uint _startTime , uint duration ) external onlyElectionCommission
    {
        startTime = _startTime;
        endTime =_startTime +duration;
    }
    function votingStatus() public view returns(string memory)
    {
        if(startTime==0)
        {
            return "Voting is Yet to Begin";
        }
        else if(block.timestamp<endTime && stopVoting == false )
        {
            return "voting on";
        }
        else 
        {
            return "Voting is ended ";
        }
    }
    function result() external onlyElectionCommission()
    {
        uint max = 0 ;
        for(uint i = 1 ; i<nextCandidateId ; i++ )
        {
            if(candidateDetails[i].votes > max)
            {
                max = candidateDetails[i].votes;
                winner = candidateDetails[i].candidtaeAddress;
            }
        }
    }
    function emergency() external onlyElectionCommission()
    {
        stopVoting = true;
    }
}
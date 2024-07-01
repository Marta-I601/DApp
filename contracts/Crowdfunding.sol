
pragma solidity ^0.8.0;


contract Crowdfunding {
    struct Project {
        uint id;
        string name;
        string description;
        uint targetAmount;
        uint currentAmount;
        uint deadline;
        address payable owner;
    }

    mapping(uint => Project) public projects;
    uint public projectCount;

    event ProjectCreated(
        uint id,
        string name,
        string description,
        uint targetAmount,
        uint deadline,
        address owner
    );

    event DonationReceived(uint projectId, uint amount, address donor);
    event FundsWithdrawn(uint projectId, uint amount);

    function createProject(string memory _name, string memory _description, uint _targetAmount, uint _durationInDays) public {
        projectCount++;
        projects[projectCount] = Project(
            projectCount,
            _name,
            _description,
            _targetAmount,
            0,
            block.timestamp + (_durationInDays * 1 days),
            payable(msg.sender)
        );
        emit ProjectCreated(projectCount, _name, _description, _targetAmount, block.timestamp + (_durationInDays * 1 days), msg.sender);
    }

    function donate(uint _projectId) public payable {
        Project storage project = projects[_projectId];
        require(block.timestamp <= project.deadline, "Deadline has passed.");
        require(msg.value > 0, "Donation amount must be greater than zero.");
        
        project.currentAmount += msg.value;
        emit DonationReceived(_projectId, msg.value, msg.sender);
    }

    function withdrawFunds(uint _projectId) public {
        Project storage project = projects[_projectId];
        require(block.timestamp > project.deadline, "Deadline has not passed.");
        require(msg.sender == project.owner, "Only the project owner can withdraw funds.");
        require(project.currentAmount >= project.targetAmount, "Funding goal not reached.");

        uint amount = project.currentAmount;
        project.currentAmount = 0;
        project.owner.transfer(amount);
        emit FundsWithdrawn(_projectId, amount);
    }
}

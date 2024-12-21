// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's ERC20 contract and Ownable contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CourseToken is ERC20, Ownable {
    constructor() ERC20("CourseToken", "CRT") Ownable(msg.sender) {
        _mint(address(this), 1000000 * 10 ** decimals()); // Mint initial supply to the contract itself
    }

    function distributeReward(address recipient, uint256 amount) external onlyOwner {
        require(balanceOf(address(this)) >= amount, "Insufficient tokens");
        _transfer(address(this), recipient, amount);
    }
}

contract CourseCompletionRewards {
    struct Course {
        uint256 id;
        string name;
        string description;
        uint256 rewardAmount;
        address instructor;
        bool exists;
    }

    CourseToken public courseToken;
    uint256 public courseCount = 0;

    mapping(uint256 => Course) public courses;
    mapping(address => mapping(uint256 => bool)) public completedCourses;

    event CourseAdded(uint256 courseId, string name, address instructor);
    event CourseCompleted(uint256 courseId, address student, uint256 rewardAmount);

    constructor(address tokenAddress) {
        courseToken = CourseToken(tokenAddress);
    }

    function addCourse(string memory name, string memory description, uint256 rewardAmount) external {
        require(rewardAmount > 0, "Reward amount must be greater than zero");

        courseCount++;
        courses[courseCount] = Course({
            id: courseCount,
            name: name,
            description: description,
            rewardAmount: rewardAmount,
            instructor: msg.sender,
            exists: true
        });

        emit CourseAdded(courseCount, name, msg.sender);
    }

    function completeCourse(uint256 courseId) external {
        require(courses[courseId].exists, "Course does not exist");
        require(!completedCourses[msg.sender][courseId], "Course already completed");

        completedCourses[msg.sender][courseId] = true;

        uint256 rewardAmount = courses[courseId].rewardAmount;
        courseToken.distributeReward(msg.sender, rewardAmount);

        emit CourseCompleted(courseId, msg.sender, rewardAmount);
    }

    function getCourseDetails(uint256 courseId)
        external
        view
        returns (
            string memory name,
            string memory description,
            uint256 rewardAmount,
            address instructor
        )
    {
        require(courses[courseId].exists, "Course does not exist");
        Course memory course = courses[courseId];
        return (course.name, course.description, course.rewardAmount, course.instructor);
    }
}

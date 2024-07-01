const Crowdfunding = artifacts.require("Crowdfunding");

contract("Crowdfunding", (accounts) => {
    let crowdfunding;

    before(async () => {
        crowdfunding = await Crowdfunding.deployed();
    });

    it("should create a project", async () => {
        await crowdfunding.createProject("Project 1", "Description 1", 100, 30, { from: accounts[0] });
        const project = await crowdfunding.projects(1);
        assert.equal(project.name, "Project 1");
        assert.equal(project.description, "Description 1");
        assert.equal(project.targetAmount, 100);
        assert.equal(project.owner, accounts[0]);
    });

    it("should receive donations", async () => {
        await crowdfunding.donate(1, { from: accounts[1], value: 50 });
        const project = await crowdfunding.projects(1);
        assert.equal(project.currentAmount, 50);
    });

    it("should allow withdrawal of funds", async () => {
        
        await new Promise((resolve, reject) => setTimeout(resolve, 30 * 24 * 60 * 60 * 1000));
        await crowdfunding.withdrawFunds(1, { from: accounts[0] });
        const project = await crowdfunding.projects(1);
        assert.equal(project.currentAmount, 0);
    });
});

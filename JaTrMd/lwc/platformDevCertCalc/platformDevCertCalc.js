import { LightningElement, track } from 'lwc';

export default class PlatformDevCertCalc extends LightningElement {
    devFundamentalScore = 50;
    procAutomationScore = 50;
    userInterfaceScore = 50;
    testDebugDeployScore = 50;
    numberOfQuestions = 60;

    certificationScore = 50;

    showResources = false;
    showGoodJob = false;
 
    generateRandom(){
        return Math.floor(Math.random() * 100);
    }
 
    @track attemptHistory = [];

    startingVals = [1,2,3,4];
    connectedCallback(){
        let dummyAttempt = {};
        for(let i=0; i<this.startingVals.length; i++){
            dummyAttempt = {Id: this.startingVals[i], Score: this.generateRandom()}
            this.attemptHistory.push(dummyAttempt);
        }
    }

    calculateScore(){
        this.certificationScore = (this.devFundamentalScore * 0.23) + 
        (this.procAutomationScore * 0.30) + (this.userInterfaceScore * 0.25) 
        + (this.testDebugDeployScore * 0.22);
        if(this.certificationScore < 0 || this.certificationScore > 100){
            alert("Certification score error. Please check your inputs");
            this.certificationScore = 0;
        }
       this.showResourcesIfFailed();
       this.addAttemptHistory(this.certificationScore);
    }

    handleChange(event){
        const inputName = event.target.name;
        let value = Number(event.target.value);
        if(inputName === 'devFundamentals'){
                this.devFundamentalScore = value;
        } else if (inputName === 'procAutomation'){
                this.procAutomationScore = value;
        } else if (inputName === 'userInterface'){
                this.userInterfaceScore = value;
        } else if (inputName === 'testDebugDeploy'){
                this.testDebugDeployScore = value;
        } else {
            alert('Error with input number');
        }
    }

    handleClick(event){
        this.calculateScore();
    }

    showResourcesIfFailed(){
        if(this.certificationScore < 68){
            this.showResources = true;
        } else {
            this.showResources = false;
        }
        this.showGoodJob = !this.showResources;
    }

        addAttemptHistory(score){
        let attemptNum = (this.attemptHistory.length + 1);
        const attempt = {
                            Id:attemptNum, Score:score
                        }
        this.attemptHistory = [...this.attemptHistory, attempt];
    }

    deleteAttemptHandler(event){
        let attemptNum = event.detail;
        this.attemptHistory = this.attemptHistory.filter(attempt => attempt.Id != attemptNum );
        console.log('New attempt history: ' + this.attmeptHistory);
    }

  
}
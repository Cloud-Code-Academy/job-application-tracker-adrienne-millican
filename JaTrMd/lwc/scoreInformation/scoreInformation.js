import { LightningElement, api } from 'lwc';

export default class ScoreInformation extends LightningElement {
    @api score;
    @api attemptNum;
    @api numberOfQuestions;

    get numberOfQuestionsCorrect(){
        return Math.floor((this.score/100) * this.numberOfQuestions);
    }

    get numberOfQuestionsIncorrect(){
        let incor = this.numberOfQuestions - this.numberOfQuestionsCorrect;
        return incor;
    }

    handleDeleteAttempt(){
        console.log('**handleDeleteattempt', this.attemptNum);
        const deleteEvent = new CustomEvent('deleteattempt',{
            detail: this.attemptNum
        });
        this.dispatchEvent(deleteEvent);
    }
}
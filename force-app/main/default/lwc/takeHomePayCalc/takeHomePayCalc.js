import { LightningElement, api, wire, track } from 'lwc';
import getTaxRatePercentage  from '@salesforce/apex/TaxMetadataController.getTaxRatePercentage';
import getSocialSecurityRate  from '@salesforce/apex/FederalRatesMetadataController.getSocialSecurityRate';
import getMedicareRate  from '@salesforce/apex/FederalRatesMetadataController.getMedicareRate';
import getStandardDeduction  from '@salesforce/apex/DeductionMetadataController.getStandardDeduction';

export default class takeHomePayCalc extends LightningElement {
    @api recordId;
    @api fieldName = 'Salary__cc';
    howPaidVal = null;
    payFrequencyVal = null;
    filingStatusVal = null;
    salAmt = null;
    taxableSalary = 0.0;
    hrsWkd = null;
    hrlyRate = null;
    addtlPretaxDeductAmt= 0.00;
    addtlPosttaxDeductAmt = 0.00;
    extraTax = 0.0;
    addtlIncome = 0.00;
    taxBr = null;
    medicareRate = null;
    socSecRate = null;
    stdDeduct = null;
    error = null;
    currYr = 0;
    timesPerYear = 0;
    takeHomePay = 0.00;
    fedExemptValue = null;
    medExemptValue = null;
    socExemptValue = null;
    isSenior = null;
    isBlind = null;
    showCalculate = false;
    showSalaried = false;
    showHourly = false;


    showButtonIfAllValuesPopulated(){
    if (this.howPaidVal !== null &&
        ((this.howPaidVal === 'Hourly' &&
        this.hrsWkd !== null &&
         this.payFrequencyVal !== null &&
        this.hrlyRate !== null) ||
        (this.howPaidVal === 'Salaried' &&
        this.payFrequencyVal !== null &&
        this.salAmt !== null)) &&
        this.filingStatusVal !== null &&
        this.fedExemptValue !== null &&
        this.medExemptValue !== null &&
        this.socExemptValue !== null &&
        this.isSenior !== null &&
        this.isBlind !== null) {
            this.showCalculate = true; 
         } else {
            this.showCalculate = false;
        }
    }

    showSalariedOptions(){
        if (this.howPaidVal === 'Salaried'){
           this.showSalaried = true; 
            this.showLump = false;

        } else if(this.howPaidVal === 'Hourly') {
            this.showHourly = true;
            this.showSalaried = false;
        
        } else {
            this.showHourly = false;
            this.showSalaried = false;
        }
    }
 
    get howPaidOptions(){
        return [
            { label: 'Hourly', value: 'Hourly' },
            { label: 'Salaried Annually', value: 'Salaried' }
        ];
    }
    
    get payFreqOptions(){
        return [
            { label: 'Weekly', value: 'Weekly' },
            { label: 'Biweekly', value: 'Biweekly' },
            { label: 'Semimonthly', value: 'SemiM' },
            { label: 'Monthly', value: 'Monthly' },
            { label: 'Quarterly', value: 'Quarterly' },
            { label: 'SemiYearly', value: 'SemiY' },
            { label: 'Yearly', value: 'Yearly' }
        ];
    }

      get filingStatusOptions(){
        return [
            { label: 'Single', value: 'SIN' },
            { label: 'Married Filing Jointly', value: 'MFJ' },
            { label: 'Married Filling Separately', value: 'MFS' },
            { label: 'Head of Household', value: 'HOH' },
        ];
    }

       get radioOptions(){
        return [
            { label: 'Yes', value: 'Y' },
            { label: 'No', value: 'N'},
        ];
    }

     getCurrentYear(){
        this.currYr = new Date().getFullYear();
    }


    @wire(getTaxRatePercentage, { filingStatusVal: '$filingStatusVal', taxableSalary: '$taxableSalary', currYr: '$currYr' }) taxBr 
    ({ error, data }) {
       if (data) {
           this.taxBr = data;
            console.log('*taxBracket: ' + this.taxBr);
       } else if (error) {
           this.error = error;
           console.log('**Error from getTaxRatePercentage: ' + this.error);
    }
   }

   
    @wire(getStandardDeduction, { filingStatusVal: '$filingStatusVal', currYr: '$currYr' }) stdDeduct 
    ({ error, data }) {
       if (data) {
           this.stdDeduct = data;
           console.log('**stdDeduction amt: ' + this.stdDeduct);
       } else if (error) {
           this.error = error;
           console.log('**Error from getStandardDeduction: ' + this.error);
    }
   }


     @wire(getSocialSecurityRate, {currYr: '$currYr' }) socSecRate
    ({ error, data }) {
       if (data) {
           this.socSecRate = data;
             console.log('**socSecRate: ' + this.socSecRate);
       } else if (error) {
           this.error = error;
           console.log('**Error from getSocialSecurityRate: ' + this.error);
    }
   }

   
     @wire(getMedicareRate, {currYr: '$currYr' }) medicareRate
    ({ error, data }) {
       if (data) {
           this.medicareRate = data;
        console.log('**medicareRate: ' + this.medicareRate);
       } else if (error) {
           this.error = error;
           console.log('**Error from getMedicareRate: ' + this.error);
    }
   }
    
    connectedCallback(){
        this.getCurrentYear(); 
    }

      handleHowPaidChange(event){
        this.howPaidVal = event.detail.value;
        console.log('**howPaidVal: ' + this.howPaidVal);
        this.showButtonIfAllValuesPopulated();
        this.showSalariedOptions();
    }

     handlePayFreqChange(event){
        this.payFrequencyVal = event.detail.value;
        console.log('**payFrequencyVal: ' + this.payFrequencyVal);
        this.convertPayFrequencyToNumberPerYear();
        this.showButtonIfAllValuesPopulated();
    }

     handleFilingStatusChange(event){
        if(this.filingStatusVal !== null && this.filingStatusVal.includes('_')){
        let filing =  this.filingStatusVal.slice(0,3);
        this.filingStatusVal = this.filingStatusVal.replace(filing,event.detail.value);
        } else {
            this.filingStatusVal = event.detail.value;
        }
       console.log('**filingStatusVal after event capture: ' + this.filingStatusVal);
        this.showButtonIfAllValuesPopulated();
    }

    handleNumericChange(event){
        const inputName = event.target.name;
        let value = Number(event.target.value);
        if (inputName === 'salaryAmount'){
            this.salAmt = value;
            console.log('**salAmt value ' + this.salAmt);
            this.showButtonIfAllValuesPopulated();
        } else if (inputName === 'hrsWorked'){
            this.hrsWkd = value;
            console.log('**hrsWkd value ' + this.hrsWkd);
            this.showButtonIfAllValuesPopulated();
        } else if (inputName === 'hrlyRate'){
            this.hrlyRate = value;
            console.log('**hrlyRate value ' + this.hrlyRate);
            this.showButtonIfAllValuesPopulated();
        } else if (inputName === 'addtlPretaxDeductAmt'){
            this.addtlPretaxDeductAmt= value;
             console.log('**addtlPretaxDeductAmtvalue ' + this.addtlPretaxDeductAmt);
        } else if (inputName === 'addtlPosttaxDeductAmt'){
            this.addtlPosttaxDeductAmt = value;
             console.log('**addtlPosttaxDeductAmt value ' + this.addtlPosttaxDeductAmt);
        } else if (inputName === 'extraTax'){
            this.extraTax = value;
             console.log('**extraTax value ' + this.extraTax);
        } else if (inputName === 'addtlIncome'){
            this.addtlIncome = value;
             console.log('**addtlIncome value ' + this.addtlIncome);
        } else {
            console.log(value);
            alert('Error with input number');
        }
    }

    handleExemptFederalChange(event){
        this.fedExemptValue = event.target.value;
        console.log('**fedExemptValue: ' + this.fedExemptValue);
        this.showButtonIfAllValuesPopulated();
    }

    handleExemptMedicareChange(event){
        this.medExemptValue = event.target.value;
         console.log('**medExemptValue: ' + this.medExemptValue);
         this.showButtonIfAllValuesPopulated();
    }

    handleStandardExemptChange(event){
        this.showDeduct = event.target.value;
         console.log('**showDeduct: ' + this.showDeduct);
    }

    handleExemptSocChange(event){
        this.socExemptValue = event.target.value;
         console.log('**socExemptValue: ' + this.socExemptValue);
    this.showButtonIfAllValuesPopulated();
    }

    handleIsBlind(event){
        this.isBlind = event.target.value;
         console.log('**isBlindValue: ' + this.isBlind);
         if(this.isBlind === 'Y') {
            this.filingStatusVal.includes('_BL') ? this.filingStatusVal : this.filingStatusVal += '_BL';
         } else {
            this.filingStatusVal.includes('_BL') ? this.filingStatusVal = this.filingStatusVal.replaceAll('_BL','') : this.filingStatusVal;
         }
        console.log('**Filing status value: ' + this.filingStatusVal);
         this.showButtonIfAllValuesPopulated();
    }

    handleIsSenior(event){
        this.isSenior = event.target.value;
         console.log('**isSeniorValue: ' + this.isSenior);
        if(this.isSenior === 'Y') {
            this.filingStatusVal.includes('_SR') ? this.filingStatusVal : this.filingStatusVal +='_SR';
         } else {
            this.filingStatusVal.includes('_SR') ? this.filingStatusVal = this.filingStatusVal.replaceAll('_SR','') : this.filingStatusVal;
         }
        console.log('**Filing status value: ' + this.filingStatusVal);
         this.showButtonIfAllValuesPopulated();
    }

    
    calculateGrossHourlySalary=() =>{
       this.salAmt = Number(this.hrsWkd * this.hrlyRate * this.timesPerYear);
       console.log('**Salary amt: ' + this.salAmt);
       return this.salAmt;
    }

    convertPayFrequencyToNumberPerYear(){
        switch(this.payFrequencyVal){
            case 'Weekly':
                this.timesPerYear = 52;
                break;
            case 'Biweekly':
                this.timesPerYear = 26;
                break;
            case 'SemiM':
                this.timesPerYear = 24;
                break;
            case 'Monthly':
                this.timesPerYear = 12;
                break;
            case 'Quarterly':
                this.timesPerYear = 4;
                break;
            case 'SemiY':
                this.timesPerYear = 2;
                break;
            case 'Yearly':
                this.timesPerYear = 1;
                break;
            default:
                console.log('**Error converting pay frequency to number');
        }
        console.log('**timesPerYear: ' +  this.timesPerYear);
    }

    calculatePayPeriodAmtForAnnualSalary(){
        let payPeriodAmt = 0;
        payPeriodAmt = this.salAmt/this.convertPayFrequencyToNumberPerYear();
        console.log('**PayPeriodAmt: ' + payPeriodAmt);
        return payPeriodAmt;
    }

    calculateYearlyPretaxDeductions(){
        let yrlyPretaxDeduct = (this.addtlPretaxDeductAmt * this.timesPerYear);
        console.log('**yrlyPretaxDeductionAmt: ' + yrlyPretaxDeduct);
        return yrlyPretaxDeduct;
    }
    
       calculateYearlyPosttaxDeductions(){
        let yrlyPosttaxDeduct = (this.addtlPosttaxDeductAmt * this.timesPerYear);
        console.log('**yrlyPosttaxDeductionAmt: ' + yrlyPosttaxDeduc);
        return yrlyPosttaxDeduct;
    }
    
    calculateTaxableIncome(){
        this.taxableSalary = (this.salAmt + this.addtlIncome) - (this.stdDeduct + this.calculateYearlyPretaxDeductions());
        console.log('**Taxable salary: ' + this.taxableSalary);
        return this.taxableSalary;
    }

    calculateExtraTax(){
        let taxPaid = this.extraTax * this.timesPerYear;
        console.log('**Tax paid: ' + taxPaid);
        return taxPaid; 
    }

    handleClick(event){
       if (this.howPaidVal === 'Hourly' ){
            this.calculateGrossHourlySalary();
        }
        this.calculateTaxableIncome();
    }

}
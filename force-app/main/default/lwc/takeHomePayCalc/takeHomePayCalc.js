import { LightningElement, api, wire, track } from 'lwc';
import getTaxRatePercentage  from '@salesforce/apex/TaxMetadataController.getTaxRatePercentage';
import getFederalRate  from '@salesforce/apex/FederalRatesMetadataController.getFederalRate';

export default class takeHomePayCalc extends LightningElement {
    @api recordId;
    @api fieldName = 'Salary__cc';
    salaryTypeVal = null;
    payFrequencyVal = null;
    filingStatusVal = null;
    salAmt = null;
    addtlDeductAmt = null;
    addtlWithholdAmt = null;
    taxBr = 0.0;
    medicareRate = 0.0;
    socSecRate = 0.0;
    rateType = null;
    error = null;
    rate = 0.0;
    currYr = 0;
    takeHomePay = 0.00;
    fedExemptValue = null;
    medExemptValue = null;
    socExemptValue = null;
    @track showCalculate = false;

    federalRates = ['Medicare', 'Social Security'];

    
    showButtonIfAllValuesPopulated(){
    if (this.salaryTypeVal !== null &&
        this.payFrequencyVal !== null &&
        this.filingStatusVal !== null &&
        this.salAmt !== null &&
        this.fedExemptValue !== null &&
        this.medExemptValue !== null &&
        this.socExemptValue !== null) {
            this.showCalculate = true; 
         } else {
            this.showCalculate = false;
        }
    
    }
 
    get salaryOptions(){
        return [
            { label: 'Hourly', value: 'Hourly' },
            { label: 'Salaried', value: 'Salaried' },
            { label: 'Lump Sum', value: 'Lump' }
        ];
    }
    
    get payFreqOptions(){
        return [
            { label: 'Paid Once', value: 'Once' },
            { label: 'Weekly', value: 'Weekly' },
            { label: 'Biweekly', value: 'Biweekly' },
            { label: 'Semimonthly', value: 'Semi' },
            { label: 'Monthly', value: 'Monthly' }
        ];
    }

      get filingStatusOptions(){
        return [
            { label: 'Single', value: 'S' },
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
        console.log('**Current year: ' + this.currYr);
    }

    getSocialSecurityRate(){
           console.log('**Social Security Rate: ' + this.socSecRate);
    }

      getMedicareRate(){
            console.log('**Medicare Rate: ' + this.medicareRate);
    }

    @wire(getTaxRatePercentage, { filingStatusVal: '$filingStatusVal', salAmt: '$salAmt', currYr: '$currYr' }) taxBr 
    ({ error, data }) {
       if (data) {
           this.taxBr = data;
       } else if (error) {
           this.error = error;
           console.log('**Error from getTaxRatePercentage: ' + error);
    }
   }

     @wire(getFederalRate, { rateType: '$rateType', currYr: '$currYr' }) rate
    ({ error, data }) {
       if (data) {
           this.rate = data;
       } else if (error) {
           this.error = error;
           console.log('**Error from getFederalRate: ' + error);
    }
   }
    
      handleSalaryTypeChange(event){
        this.salaryTypeVal = event.detail.value;
        console.log('**salaryTypeVal: ' + this.salaryTypeVal);
        this.showButtonIfAllValuesPopulated();
    }

     handlePayFreqChange(event){
        this.payFrequencyVal = event.detail.value;
        console.log('**payFrequencyVal: ' + this.payFrequencyVal);
        this.showButtonIfAllValuesPopulated();
    }

     handleFilingStatusChange(event){
        this.filingStatusVal = event.detail.value;
        console.log('**filingStatusVal: ' + this.filingStatusVal);
        this.showButtonIfAllValuesPopulated();
    }

    handleNumericChange(event){
        const inputName = event.target.name;
        let value = Number(event.target.value);
        if (inputName === 'salaryAmount'){
            this.salAmt = value;
            console.log('**salAmt value ' + this.salAmt);
            this.showButtonIfAllValuesPopulated();
        } else if (inputName === 'addtlDeductAmt'){
            this.addtlDeductAmt = value;
            this.showButtonIfAllValuesPopulated();
             console.log('**addtlDeductAmt value ' + this.addtlDeductAmt);
        } else if (inputName === 'addtlWithholdingAmt'){
            this.addtlWithholdAmt = value;
             console.log('**addtlWithholdAmt value ' + this.addtlWithholdAmt);
             this.showButtonIfAllValuesPopulated();
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


    handleExemptSocChange(event){
        this.socExemptValue = event.target.value;
         console.log('**socExemptValue: ' + this.socExemptValue);
    this.showButtonIfAllValuesPopulated();
    }

    handleClick(event){
        this.getCurrentYear();
        this.getSocialSecurityRate();
        this.getMedicareRate();
        alert('Tax bracket: ' + this.taxBr);
    }

}
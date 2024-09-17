import { LightningElement, api, wire } from 'lwc';
import getTaxRatePercentage  from '@salesforce/apex/TaxMetadataController.getTaxRatePercentage';
import getFederalRate  from '@salesforce/apex/FederalRatesMetadataController.getFederalRate';

export default class takeHomePayCalc extends LightningElement {
    @api recordId;
    @api fieldName = 'Salary__cc';
    salaryTypeVal = '';
    payFrequencyVal = '';
    filingStatusVal = '';
    salAmt = 0.0;
    taxBr = 0.0;
    medicareRate = 0.0;
    socSecRate = 0.0;
    error = '';
    addtlDeductAmt = 0.0;
    addtlWithholdAmt = 0.0;
    currYr = 0;
    
    takeHomePay = 0.00;

    fedExemptValue = false;
    medExemptValue = false;
    socExemptValue = false;

    federalRates = [ { name: 'Medicare', rate: 0.0},
                    { name: 'Social Security', rate: 0.0}];
 
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
    }

    @wire(getTaxRatePercentage, { filingStatusVal: '$filingStatusVal', salAmt: '$salAmt', currYr: '$currYr' }) taxBr 
    ({ error, data }) {
       if (data) {
           this.taxBr = data;
       } else if (error) {
           this.error = error;
           alert(error);
    }
   }

     @wire(getFederalRate, { rateType: '$rateType', currYr: '$currYr' }) federalRates
    ({ error, data }) {
       if (data) {
           this.rate = data;
       } else if (error) {
           this.error = error;
           alert(error);
    }
   }
    
      handleSalaryTypeChange(event){
        this.salaryTypeVal = event.detail.value;
    }

     handlePayFreqChange(event){
        this.payFrequencyVal = event.detail.value;
    }

     handleFilingStatusChange(event){
        this.filingStatusVal = event.detail.value;
    }

    handleNumericChange(event){
        const inputName = event.target.name;
        let value = Number(event.target.value);
        if (inputName === 'salaryAmount'){
            this.salAmt = value;
        } else if (inputName === 'addtlDeductAmt'){
            this.addtlDeductAmt = value;
        } else if (inputName === 'addtlWithholdAmt'){
            this.addtlWithholdAmt = value;
        } else {
            alert('Error with input number');
        }
    }

    handleExemptFederalChange(event){
        this.fedExemptValue = event.target.value;
    }

    handleExemptMedicareChange(event){
        this.medExemptValue = event.target.value;
    }

    handleExemptSocChange(event){
        this.socExemptValue = event.target.value;
    }

    handleClick(event){
        alert('Tax bracket: ' + this.taxBr);
    }
  
}
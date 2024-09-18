import { LightningElement, api, wire, track } from 'lwc';
import getTaxRatePercentage  from '@salesforce/apex/TaxMetadataController.getTaxRatePercentage';
import getSocialSecurityRate  from '@salesforce/apex/FederalRatesMetadataController.getSocialSecurityRate';
import getMedicareRate  from '@salesforce/apex/FederalRatesMetadataController.getMedicareRate';

export default class takeHomePayCalc extends LightningElement {
    @api recordId;
    @api fieldName = 'Salary__cc';
    howPaidVal = null;
    payFrequencyVal = null;
    filingStatusVal = null;
    salAmt = null;
    hrsWkd = null;
    addtlDeductAmt = null;
    addtlWithholdAmt = null;
    taxBr = 0.0;
    @track medicareRate = 0.0;
    @track socSecRate = 0.0;
    error = null;
    currYr = 0;
    takeHomePay = 0.00;
    fedExemptValue = null;
    medExemptValue = null;
    socExemptValue = null;
    showCalculate = false;
    showSalaried = false;
    showHourly = false;
    showLump = false;

    
    showButtonIfAllValuesPopulated(){
    if (this.howPaidVal !== null &&
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

    showSalariedOptions(){
        if (this.howPaidVal === 'Salaried'){
           this.showSalaried = true; 
            this.showHourly = false;
            this.showLump = false;

        } else if(this.howPaidVal === 'Hourly') {
            this.showHourly = true;
            this.showSalaried = false;
            this.showLump = false;
        }
        else if (this.howPaidVal === 'Lump'){
            this.showHourly = false;
            this.showSalaried = false;
            this.showLump = true;
        } else {
            this.showHourly = false;
            this.showSalaried = false;
            this.showLump = false;
        }

    }
 
    get howPaidOptions(){
        return [
            { label: 'Hourly', value: 'Hourly' },
            { label: 'Salaried Annually', value: 'Salaried' },
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
           console.log('**Error from getTaxRatePercentage: ' + error);
    }
   }

     @wire(getSocialSecurityRate, {currYr: '$currYr' }) socSecRate
    ({ error, data }) {
       if (data) {
           this.socSecRate = data;
       } else if (error) {
           this.error = error;
           console.log('**Error from getSocialSecurityRate: ' + error);
    }
   }

   
     @wire(getMedicareRate, {currYr: '$currYr' }) medicareRate
    ({ error, data }) {
       if (data) {
           this.medicareRate = data;
       } else if (error) {
           this.error = error;
           console.log('**Error from getMedicareRate: ' + error);
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
        }else if (inputName === 'lumpSalaryAmount'){
            this.salAmt = value;
            console.log('**salAmt value ' + this.salAmt);
            this.showButtonIfAllValuesPopulated();
        } else if (inputName === 'hrsWorked'){
            this.hrsWkd = value;
            console.log('**hrsWkd value ' + this.hrsWkd);
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
        alert('Tax bracket: ' + this.taxBr);
    }

}
import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getTaxBracketName from "@salesforce/apex/TaxMetadataController.getTaxBracketName";
import getTaxRateForTaxBracketName from "@salesforce/apex/TaxMetadataController.getTaxRateForTaxBracketName";
import getStartingSalaryForTaxBracketName from "@salesforce/apex/TaxMetadataController.getStartingSalaryForTaxBracketName";
import getEndingSalaryForTaxBracketName from "@salesforce/apex/TaxMetadataController.getEndingSalaryForTaxBracketName";
import getSocialSecurityRate from "@salesforce/apex/FederalRatesMetadataController.getSocialSecurityRate";
import getSocialSecurityMaxVal from "@salesforce/apex/FederalRatesMetadataController.getSocialSecurityMaxVal";
import getMedicareRate from "@salesforce/apex/FederalRatesMetadataController.getMedicareRate";
import getStandardDeduction from "@salesforce/apex/DeductionMetadataController.getStandardDeduction";
import SALARY_FIELD from "@salesforce/schema/Job_Application__c.Salary__c";
import PAID_FIELD from "@salesforce/schema/Job_Application__c.How_Paid__c";

const FIELDS = [SALARY_FIELD, PAID_FIELD];
export default class takeHomePayCalc extends LightningElement {
  @api recordId;
  howPaidVal = null;
  payFrequencyVal = null;
  filingStatusVal = null;
  salAmt = null;
  hrsWkd = null;
  hrlyRate = null;
  addtlPretaxDeductAmt = 0.0;
  addtlPosttaxDeductAmt = 0.0;
  extraTaxPerPayPeriod = 0.0;
  addtlIncome = 0.0;
  taxableInc= 0.0;
  maxTaxBracket = "";
  medicareRate = null;
  socSecRate = null;
  socSecMaxVal = null;
  stdDeduct = null;
  itmDeduct = 0.0;
  error = null;
  currYr = 0;
  timesPerYear = 0;
  takeHomePay = 0.0;
  fedTax = null;
  socSecTax = null;
  medTax = null;
  grossSalDiv = null;
  fedExemptValue = null;
  medExemptValue = null;
  socExemptValue = null;
  isSenior = null;
  isBlind = null;
  showCalculate = false;
  showSalaried = false;
  showHourly = false;
  hasFilingStatus = false;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  loadFields({ error, data }) {
    if (error) {
      this.error = error;
      console.log(error);
    } else if (data) {
      this.howPaidVal = getFieldValue(data, PAID_FIELD);
      this.salAmt = getFieldValue(data, SALARY_FIELD);
      console.log('**howPaidVal: ' + this.howPaidVal);
      console.log('**sal Amt: ' + this.salAmt);
      if (this.howPaidVal === "Salaried") {
        this.showSalaried = true;
      } else {
        this.showHourly = true;
      }
    }
  }

async showButtonIfAllValuesPopulated() {
    if (
      this.howPaidVal !== null &&
      ((this.howPaidVal === "Hourly" &&
        this.hrsWkd !== null &&
        this.payFrequencyVal !== null &&
        this.hrlyRate !== null) ||
        (this.howPaidVal === "Salaried" &&
          this.payFrequencyVal !== null &&
          this.salAmt !== null)) &&
      this.filingStatusVal !== null &&
      this.fedExemptValue !== null &&
      this.medExemptValue !== null &&
      this.socExemptValue !== null &&
      this.isSenior !== null &&
      this.isBlind !== null
    ) {
      this.showCalculate = true;
      this.calculateTaxableIncome();
      await this.handleGetMaxTaxBracketName();
      console.log("**Max tax bracket name: " + this.maxTaxBracket);
    } else {
      this.showCalculate = false;
      this.maxTaxBracket = null;
      this.taxableInc = 0.0;
    }
  }

  showSalariedOptions() {
    if (this.howPaidVal === "Salaried") {
      this.showSalaried = true;
      this.showLump = false;
    } else if (this.howPaidVal === "Hourly") {
      this.showHourly = true;
      this.showSalaried = false;
    } else {
      this.showHourly = false;
      this.showSalaried = false;
    }
  }

  get howPaidOptions() {
    return [
      { label: "Hourly", value: "Hourly" },
      { label: "Salaried", value: "Salaried" }
    ];
  }

  get payFreqOptions() {
    return [
      { label: "Weekly", value: "Weekly" },
      { label: "Biweekly", value: "Biweekly" },
      { label: "Semimonthly", value: "SemiM" },
      { label: "Monthly", value: "Monthly" },
      { label: "Quarterly", value: "Quarterly" },
      { label: "SemiYearly", value: "SemiY" },
      { label: "Yearly", value: "Yearly" }
    ];
  }

  get filingStatusOptions() {
    return [
      { label: "Single", value: "SIN" },
      { label: "Married Filing Jointly", value: "MFJ" },
      { label: "Married Filling Separately", value: "MFS" },
      { label: "Head of Household", value: "HOH" }
    ];
  }

  get radioOptions() {
    return [
      { label: "Yes", value: "Y" },
      { label: "No", value: "N" }
    ];
  }

  getCurrentYear() {
    this.currYr = new Date().getFullYear();
  }

  @wire(getStandardDeduction, {
    filingStatusVal: "$filingStatusVal",
    currYr: "$currYr"
  })
  stdDeduct({ error, data }) {
    if (data) {
      this.stdDeduct = data;
      console.log("**stdDeduction amt: " + this.stdDeduct);
    } else if (error) {
      this.error = error;
      console.log("**Error from getStandardDeduction: " + this.error);
    }
  }

  @wire(getSocialSecurityRate, { currYr: "$currYr" }) socSecRate({
    error,
    data
  }) {
    if (data) {
      this.socSecRate = data;
      console.log("**socSecRate: " + this.socSecRate);
    } else if (error) {
      this.error = error;
      console.log("**Error from getSocialSecurityRate: " + this.error);
    }
  }

  @wire(getSocialSecurityMaxVal, { currYr: "$currYr" }) socSecMaxVal({
    error,
    data
  }) {
    if (data) {
      this.socSecMaxVal = data;
      console.log("**socSecMaxVal: " + this.socSecMaxVal);
    } else if (error) {
      this.error = error;
      console.log("**Error from getSocialSecurityMaxVal: " + this.error);
    }
  }

  @wire(getMedicareRate, { currYr: "$currYr" }) medicareRate({ error, data }) {
    if (data) {
      this.medicareRate = data;
      console.log("**medicareRate: " + this.medicareRate);
    } else if (error) {
      this.error = error;
      console.log("**Error from getMedicareRate: " + this.error);
    }
  }
  
  
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  loadFields({ error, data }) {
    if (error) {
      this.error = error;
      console.log(error);
    } else if (data) {
      this.howPaidVal = getFieldValue(data, PAID_FIELD);
      this.salAmt = getFieldValue(data, SALARY_FIELD);
      console.log('**howPaidVal: ' + this.howPaidVal);
      console.log('**sal Amt: ' + this.salAmt);
      if (this.howPaidVal === "Salaried") {
        this.showSalaried = true;
      } else {
        this.showHourly = true;
      }
    }
  }


  connectedCallback() {
    this.getCurrentYear();
  }

  handleHowPaidChange(event) {
    this.howPaidVal = event.detail.value;
    console.log("**howPaidVal: " + this.howPaidVal);
    this.showButtonIfAllValuesPopulated();
    this.showSalariedOptions();
  }

  handlePayFreqChange(event) {
    this.payFrequencyVal = event.detail.value;
    console.log("**payFrequencyVal: " + this.payFrequencyVal);
    this.convertPayFrequencyToNumberPerYear();
    this.showButtonIfAllValuesPopulated();
  }

  handleFilingStatusChange(event) {
    if (this.filingStatusVal !== null && this.filingStatusVal.includes("_")) {
      let filing = this.filingStatusVal.slice(0, 3);
      this.filingStatusVal = this.filingStatusVal.replace(
        filing,
        event.detail.value
      );
    } else {
      this.filingStatusVal = event.detail.value;
    }
    this.hasFilingStatus = true;
    console.log(
      "**filingStatusVal after event capture: " + this.filingStatusVal
    );
    this.showButtonIfAllValuesPopulated();
  }

  handleNumericChange(event) {
    const inputName = event.target.name;
    let value = Number(event.target.value);
    if (inputName === "salaryAmount") {
      this.salAmt = value;
      console.log("**salAmt value " + this.salAmt);
      this.showButtonIfAllValuesPopulated();
    } else if (inputName === "hrsWorked") {
      this.hrsWkd = value;
      console.log("**hrsWkd value " + this.hrsWkd);
      this.showButtonIfAllValuesPopulated();
    } else if (inputName === "hrlyRate") {
      this.hrlyRate = value;
      console.log("**hrlyRate value " + this.hrlyRate);
      this.showButtonIfAllValuesPopulated();
    } else if (inputName === "addtlPretaxDeductAmt") {
      this.addtlPretaxDeductAmt = value;
      console.log("**addtlPretaxDeductAmtvalue " + this.addtlPretaxDeductAmt);
    } else if (inputName === "addtlPosttaxDeductAmt") {
      this.addtlPosttaxDeductAmt = value;
      console.log(
        "**addtlPosttaxDeductAmt value " + this.addtlPosttaxDeductAmt
      );
    } else if (inputName === "extraTax") {
      this.extraTax = value;
      console.log("**extraTax value " + this.extraTax);
    } else if (inputName === "addtlIncome") {
      this.addtlIncome = value;
      console.log("**addtlIncome value " + this.addtlIncome);
    } else if (inputName === "itemizedDeduction") {
      this.itmDeduct = value;
      console.log("**itemizedDeduct value " + this.itmDeduct);
      this.handleItemizedDeduction();
    } else {
      console.log(value);
      alert("Error with input number");
    }
  }

  handleExemptFederalChange(event) {
    this.fedExemptValue = event.target.value;
    console.log("**fedExemptValue: " + this.fedExemptValue);
    this.showButtonIfAllValuesPopulated();
  }

  handleExemptMedicareChange(event) {
    this.medExemptValue = event.target.value;
    console.log("**medExemptValue: " + this.medExemptValue);
    this.showButtonIfAllValuesPopulated();
  }

  handleStandardExemptChange(event) {
    this.showDeduct = event.target.value;
    console.log("**showDeduct: " + this.showDeduct);
  }

  handleExemptSocChange(event) {
    this.socExemptValue = event.target.value;
    console.log("**socExemptValue: " + this.socExemptValue);
    this.showButtonIfAllValuesPopulated();
  }

  handleIsBlind(event) {
    this.isBlind = event.target.value;
    console.log("**isBlindValue: " + this.isBlind);
    if (!this.filingStatusVal.includes("_BL") && this.isBlind === "Y") {
      this.filingStatusVal += "_BL";
    } else if (this.filingStatusVal.includes("_BL") && this.isBlind === "N") {
      this.filingStatusVal.replaceAll("_BL", "");
    }
    console.log("**Filing status value: " + this.filingStatusVal);
    this.showButtonIfAllValuesPopulated();
  }

  handleIsSenior(event) {
    this.isSenior = event.target.value;
    console.log("**isSeniorValue: " + this.isSenior);
    if (!this.filingStatusVal.includes("_SR") && this.isSenior === "Y") {
      this.filingStatusVal += "_SR";
    } else if (this.filingStatusVal.includes("_SR") && this.isSenior === "N") {
      this.filingStatusVal = this.filingStatusVal.replaceAll("_SR", "");
    }
    console.log("**Filing status value: " + this.filingStatusVal);
    this.showButtonIfAllValuesPopulated();
  }

  handleItemizedDeduction() {
    if (this.itmDeduct > this.stdDeduct) {
      return this.itmDeduct;
    } else {
      return this.stdDeduct;
    }
  }

  calculateGrossHourlySalary = () => {
    this.salAmt = Number(this.hrsWkd * this.hrlyRate * this.timesPerYear);
    console.log("**Gross salary amt for hourly: " + this.salAmt);
    return this.salAmt;
  };

  
   calculateGrossSalaryDivided = () => {
    this.grossSalDiv = parseFloat(this.salAmt/this.timesPerYear);
    this.grossSalDiv = this.grossSalDiv.toFixed(2);
    console.log("**Gross salary amount divided: " + this.grossSalDiv);
  };

  convertPayFrequencyToNumberPerYear() {
    switch (this.payFrequencyVal) {
      case "Weekly":
        this.timesPerYear = 52;
        break;
      case "Biweekly":
        this.timesPerYear = 26;
        break;
      case "SemiM":
        this.timesPerYear = 24;
        break;
      case "Monthly":
        this.timesPerYear = 12;
        break;
      case "Quarterly":
        this.timesPerYear = 4;
        break;
      case "SemiY":
        this.timesPerYear = 2;
        break;
      case "Yearly":
        this.timesPerYear = 1;
        break;
      default:
        console.log("**Error converting pay frequency to number");
    }
    console.log("**timesPerYear: " + this.timesPerYear);
  }

  calculatePayPeriodAmtForAnnualSalary() {
    let payPeriodAmt = 0.0;
    payPeriodAmt = parseFloat(this.salAmt / this.convertPayFrequencyToNumberPerYear());
       
    return payPeriodAmt;
  }

  calculatePretaxDeductions() {
    let yrlyPretaxDeduct = this.addtlPretaxDeductAmt * this.timesPerYear;
   yrlyPretaxDeduct === undefined ? 0.0 : parseFloat(yrlyPretaxDeduct);
    return yrlyPretaxDeduct;
  }

  calculatePosttaxDeductions() {
    let yrlyPosttaxDeduct = this.addtlPosttaxDeductAmt * this.timesPerYear;
    yrlyPosttaxDeduct === undefined ? 0.0 : parseFloat(yrlyPosttaxDeduct);
    return yrlyPosttaxDeduct;
  }

  calculateTaxableIncome() {
    if (this.salAmt !== null && this.howPaidVal === "Hourly") {
      this.calculateGrossHourlySalary();
    } else if (this.salAmt !== null && this.howPaidVal === "Salaried"){
      this.calculateGrossSalaryDivided();
    }
    let deduct = this.handleItemizedDeduction();
    this.taxableInc =
      parseFloat(this.salAmt +
      this.addtlIncome -
      (deduct + this.calculatePretaxDeductions()));
    console.log(
      "**Taxable income from calculateTaxableIncome: " + this.taxableInc
    );
  }

  calculateExtraTaxPaid() {    
    let extraTaxPaid = this.extraTaxPerPayPeriod * this.timesPerYear;
    extraTaxPaid === undefined ? 0.0 : parseFloat(extraTaxPaid);
    return extraTaxPaid;
  }

  
  calculateMedicareTax() {
    let mdcrTax = 0.0;
     if(this.medExemptValue === "N"){
      mdcrTax = parseFloat((this.medicareRate / 100) * this.taxableInc);
    }
     console.log('**Medicare tax: ' + mdcrTax);
    return mdcrTax;
  }
  
  calculateSocialSecurityTax() {
    let amtTxd = this.taxableInc - this.socSecMaxVal;
    let ssTax = 0.0 ;
    if (this.socExemptValue === "N") {
         ssTax = (amtTxd <= 0) ? parseFloat((this.socSecRate / 100) * this.taxableInc) : parseFloat((this.socSecRate / 100) * amtTxd);
    }
    console.log('**Social sec tax: ' + ssTax);
    return ssTax;
  }


  async handleGetMaxTaxBracketName() {
    try {
      this.maxTaxBracket = await getTaxBracketName({
        filingStatusVal: this.filingStatusVal,
        taxableInc: this.taxableInc,
        currYr: this.currYr
      });
      this.error = undefined;

    } catch (error) {
      this.error = error;
      console.log("**Error: " + error);
    }
  }

  async handleGetStartingSalary(taxBrName) {
    try {
      let startingSal = await getStartingSalaryForTaxBracketName({
        taxBrName: taxBrName,
        currYr: this.currYr
      });

      return startingSal;
    } catch (error) {
      console.log("**Error: " + error);
      return;
    }
  }

  async handleGetEndingSalary(taxBrName) {
    try {
      let endingSal = await getEndingSalaryForTaxBracketName({
        taxBrName: taxBrName,
        currYr: this.currYr
      });
  
      return endingSal;
    } catch (error) {
      console.log("**Error: " + error);
      return;
    }
  }

  async handleGetTaxRateForTaxBracketName(taxBrName) {
    try {
      let taxBracket = await getTaxRateForTaxBracketName({
        taxBrName: taxBrName,
        currYr: this.currYr
      });
   
      this.error = undefined;
      return taxBracket;
    } catch (error) {
      console.log("**Error: " + error);
      return;
    }
  }

  async calculateFederalTaxForAGivenBracket(taxBracket, endingSalary) {
    if (taxBracket === null || taxBracket === "") {
      return 0.0;
    }
    // the async work
    const currentTaxRate =
      await this.handleGetTaxRateForTaxBracketName(taxBracket);

    const startingSalary = await this.handleGetStartingSalary(taxBracket);

    endingSalary =
      endingSalary !== null
        ? endingSalary
        : await this.handleGetEndingSalary(taxBracket);

    return await this.calculateTaxForBlock(
      endingSalary,
      startingSalary,
      currentTaxRate
    );
  }

  async calculateFederalTax() {
    const extraTax =   this.calculateExtraTaxPaid();
    const taxBrackets = [];
    const maxTaxBracketTax = parseFloat(await this.calculateFederalTaxForAGivenBracket(
      this.maxTaxBracket,
      this.taxableInc
    ));
    console.log('**max bracket tax: ' + maxTaxBracketTax);
    const maxBracketNumber = parseInt(
      this.maxTaxBracket.charAt(this.maxTaxBracket.length - 1)
    );
    
    const brSubStr = this.maxTaxBracket.substring(0, 3) + " ";

    for (let i = maxBracketNumber - 1; i >= 0; i--) {
      taxBrackets.push(brSubStr + i);
    }
    const taxCalculationPromisesByBracket = taxBrackets.map(async (bracket) => {
      return this.calculateFederalTaxForAGivenBracket(bracket, null);
    });

    const calculatedTaxes = await Promise.all(taxCalculationPromisesByBracket);
    console.log('**calculated taxes in array: ' + calculatedTaxes);

    let calcBracketTax = (calculatedTaxes.reduce((acc, tax) => parseFloat(acc + tax), 0.00)).toFixed(2);
    calcBracketTax = Number(calcBracketTax);
    console.log('**Full tax: '+ ((maxTaxBracketTax + calcBracketTax)-extraTax));

    return ((maxTaxBracketTax + calcBracketTax)-extraTax).toFixed(2);
  }

   async calculateFullTaxes(){
    try{
      this.fedTax = await this.calculateFederalTax();
      this.error = undefined;
    } catch (error){
      this.error = error;
      console.log('**Error: ' + error);
    }
    this.medTax = this.calculateMedicareTax();
    this.socSecTax = this.calculateSocialSecurityTax();
    const tax = parseFloat(this.fedTax + this.medTax + this.socSecTax).toFixed(2);
    return tax;
  }

  async calculateTaxForBlock(endingSal, startingSal, taxRate) {
    let taxPercent = taxRate / 100;
    let block = endingSal - startingSal;
    let tax = taxPercent * block;
    return tax.toFixed(2);
  }

  async handleClick(event) {
      this.calculateTaxableIncome();
      const tax = await this.calculateFullTaxes();
    console.log("**Yearly tax: " + tax);
    const yrlyTakeHome = this.salAmt - this.fedTax - this.calculatePretaxDeductions() - this.calculatePosttaxDeductions();
    this.socSecTax = (this.socSecTax/this.timesPerYear).toFixed(2);
    this.medTax = (this.medTax/this.timesPerYear).toFixed(2);
    this.fedTax = (this.fedTax/this.timesPerYear).toFixed(2);
    this.takeHomePay = (yrlyTakeHome/this.timesPerYear).toFixed(2);
  }
}
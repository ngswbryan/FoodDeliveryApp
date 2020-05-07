import { Component, OnInit } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ApiService } from "../api.service";
import { DataService } from "../data.service";
import { LoadingService } from "../loading.service";

@Component({
  selector: 'app-modal-content',
  templateUrl: './modal-content.component.html',
  styleUrls: ['./modal-content.component.css']
})
export class ModalContentComponent implements OnInit {
  title: string;
  list: any[] = []; //this list is connected to the parent component 
  minOrder: any[] = []; //this list is connected to the parent component 
  confirmedList = [];
  foodItems; //this list is connected to the parent component 
  orderList;
  total; 
  hasOrdered: boolean; 

  fdscampaigns=[];
  campaigns=[];
  discount; 
  gotDiscount: boolean;  

  constructor(
    private bsModalRef: BsModalRef,
    private apiService: ApiService,
    private dataService: DataService,
    private loadingService: LoadingService,
  ) { }

  ngOnInit() {
    this.total = 0; 
    this.discount = 0; 
    this.gotDiscount = false; 
    this.dataService.currentMessage.subscribe(hasOrdered => this.hasOrdered = hasOrdered);
    this.dataService.currentFoodItems.subscribe(foodItems => this.foodItems = foodItems);
    this.dataService.changeFoodItems([]);

    this.apiService.getFDSCampaigns().subscribe((campaigns: any) => {
      console.log("this is a takjsdnfeslrfge");
      for (let k = 0; k < campaigns.length; k++) {
        let start = campaigns[k].start_date;
        let end = campaigns[k].end_date;
        let formatted = start.substring(0, 10);
        let formmated2 = end.substring(0, 10);
        let newPromo = {
          ...campaigns[k],
          new_start: formatted,
          new_end: formmated2,
        };
        console.log(newPromo);
        this.fdscampaigns.push(newPromo);
      }
      if (this.fdscampaigns.length != 0) {
        this.applyFDSCampaign();
      }
      

      this.apiService.getCampaigns(this.list).subscribe((cam: any) => {
        for (let k = 0; k < cam.length; k++) {
          let start = cam[k].start_date;
          let end = cam[k].end_date;
          let formatted = start.substring(0, 10);
          let formmated2 = end.substring(0, 10);
          let newPromo = {
            ...cam[k],
            new_start: formatted,
            new_end: formmated2,
          };
          console.log(newPromo);
       
            this.campaigns.push(newPromo);
    
        }
      })
      if (this.campaigns.length != 0) {
        this.applyCampaign();
      }
      
    
      this.apiService.getListOfFoodItem(this.list).subscribe((fooditem: any) => {
        this.orderList = Array(fooditem.length).fill(0);

        for (let i = 0; i < fooditem.length; i++) {
          this.foodItems.push(fooditem[i]);
          // console.log(fooditem[i]);
        }
        for (let j = 0; j< this.foodItems.length; j++) {
          if (this.gotDiscount) {
          this.foodItems[j]["food_price"] = this.foodItems[j]["food_price"] * this.discount;
          }
        }
        // console.log("food items testing " + this.foodItems); 
      });

      this.loadingService.loading.next(false);
    });
    
    
  }

  applyFDSCampaign() {
    let startdate = this.fdscampaigns[0]["start_date"];
    let enddate = this.fdscampaigns[0]["end_date"];
    let discount = 1-this.fdscampaigns[0]["discount"];
    if (this.checkDate(startdate) && this.gotDiscount) {
      this.discount = this.discount + discount; 
      this.gotDiscount = true; 
    }
    
  }
  applyCampaign() {
    let startdate = this.campaigns[0]["start_date"];
    let enddate = this.campaigns[0]["end_date"];
    let discount = 1-this.campaigns[0]["discount"];
    if (this.checkDate(startdate) && this.gotDiscount) {
      this.discount = this.discount + discount; 
      this.gotDiscount = true; 
    }
    
  }

  checkDate(date) {
    let curr = new Date().toISOString();
    let currDate = new Date(curr);
    let input = new Date(date);

    if (currDate > input) {
      return true;
    } else {
      return false;
    }
  }

  checkStarted(date) {
    let curr = new Date().toISOString();
    let currDate = new Date(curr);
    let input = new Date(date);

    if (currDate > input) {
      return false;
    } else {
      return true;
    }
  }

  confirm() {
    this.confirmedList = this.orderList; 
    this.dataService.changeFoodItems(this.foodItems);
    this.dataService.changeList(this.confirmedList);
    this.dataService.changeMessage(true);
    this.dataService.changeTotal(this.total);
    this.close();
  }

  close() {
    this.bsModalRef.hide();
  }

  test() {
    console.log("campaign : " + this.fdscampaigns[0]);
  }


  addOrder(i) {
    this.orderList[i]++; 
  }

  calculateTotal() {
    let amount = 0; 
    for (let i=0; i<this.orderList.length; i++) {
      amount += this.orderList[i] * this.foodItems[i]["food_price"]
    }
    this.total = amount; 
  }

}

import { Component, OnInit } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ApiService } from "../api.service";
import { DataService } from "../data.service"

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

  constructor(
    private bsModalRef: BsModalRef,
    private apiService: ApiService,
    private dataService: DataService
  ) { }

  ngOnInit() {
    this.total = 0; 
    this.dataService.currentMessage.subscribe(hasOrdered => this.hasOrdered = hasOrdered);
    this.dataService.currentFoodItems.subscribe(foodItems => this.foodItems = foodItems);
    this.dataService.changeFoodItems([]);
    this.apiService.getListOfFoodItem(this.list).subscribe((fooditem: any) => {
      this.orderList = Array(fooditem.length).fill(0);
      for (let i = 0; i < fooditem.length; i++) {
        this.foodItems.push(fooditem[i]);
        console.log(fooditem[i]);
      }
      console.log("food items testing " + this.foodItems); 
    });
    
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

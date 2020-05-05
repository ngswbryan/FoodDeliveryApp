import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { LoadingService } from "../loading.service";
import { BsModalService, BsModalRef } from 'ngx-bootstrap/modal';
import { ModalContentComponent } from '../modal-content/modal-content.component';
import { FormGroup, FormArray, FormControl, Validators } from "@angular/forms";
import { ApiService } from "../api.service";
import { DataService } from "../data.service";
import { Router } from "@angular/router";


@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})

export class CustomerComponent implements OnInit {
  createOrderForm: FormGroup;
  hasOrdered: boolean;  
  bsModalRef: BsModalRef;
  username;
  user;
  uid;  
  rid; 

  pastDeliveries = [];
  pastReviews = [];
  restaurants = [];
  foodItems = [];
  confirmedList=[]; 
  total; 

  locationDropdown; 
  recentLocations = [];
  rewardsBal; 

  toBePaid; 
  creditCard: boolean;  //boolean : if credit card --> true if cash --> false 
  location;   //string
  orderedPairs=[];
  deliveryid; 

  confirm: boolean;

  orderOngoing: boolean; 
  
  
  constructor(
    private router : ActivatedRoute,
    private loadingService: LoadingService,
    private modalService: BsModalService,
    private apiService: ApiService,
    private dataService: DataService,
    ) { }

  ngOnInit() {
    this.toBePaid = 5; 
    this.locationDropdown = true; 
    this.orderOngoing = false; 
    this.loadingService.loading.next(true);
    this.dataService.currentMessage.subscribe(hasOrdered => this.hasOrdered = hasOrdered);
    this.dataService.currentList.subscribe(confirmedList => this.confirmedList = confirmedList);
    this.dataService.currentFoodItems.subscribe( foodItems=> this.foodItems = foodItems);
    this.dataService.currentTotal.subscribe( total => this.total = total);
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
        this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any)=> {
          console.log(test[0].uid);
          console.log(test);
          this.uid = test[0].uid; 

          this.apiService.getPastDeliveryRating(this.uid).subscribe((delivery: any) => {

            for (let i = 0; i < delivery.length; i++) {
              let current = delivery[i]["past_delivery_ratings"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.pastDeliveries.push(arr);
              // console.log("past deliveries : " + arr);
            }
            // console.log("past deliveries : " + this.pastDeliveries[1][2]);
            this.loadingService.loading.next(false);
          });

          this.apiService.getPastFoodReviews(this.uid).subscribe((review: any) => {
            
            for (let i = 0; i < review.length; i++) {
              let current = review[i]["past_food_reviews"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.pastReviews.push(arr);
            }
            this.loadingService.loading.next(false);
          });


          this.apiService.getRestaurants().subscribe((restaurant: any) => {
            
            for (let i = 0; i < restaurant.length; i++) {
              let current = restaurant[i]["list_of_restaurant"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.restaurants.push(arr);
            }
            this.loadingService.loading.next(false);
          });
          
          
        })

    })

    this.createOrderForm = new FormGroup({
      creditCard: new FormControl(""),
      location: new FormControl(""),
    });
    
  }

  submitForm() {
    console.log("confirmed list is: " + this.confirmedList); 
    console.log("foodlist is: " + this.foodItems); 
    var current = [];
    for (let i=0; i<this.foodItems.length; i++) {
      if (this.confirmedList[i] > 0) {
        console.log("food_id is : " + this.foodItems[i]["food_id"]);
        current.push([this.foodItems[i]["food_id"], this.confirmedList[i]]);
      }
    }
    console.log(current);
    this.orderedPairs = current; 
    if (!this.createOrderForm.value.creditCard) {
      window.alert("Please enter mode of payment.");
    } else if (!this.createOrderForm.value.location) {
      window.alert("Please enter a valid location");
    } else {
      this.creditCard = this.createOrderForm.value.creditCard;
      this.location = this.createOrderForm.value.location; 
    }

    let order = {
      currentorder: this.orderedPairs,
      customer_uid: this.uid,
      restaurant_id: this.rid, 
      have_credit: this.creditCard,
      total_order_cost: this.total,
      delivery_location: this.location,
    };
    console.log(order);

    this.apiService.updateOrderCount(order).subscribe((res: any) => {
      console.log("after posting" + res);
      for (let i=0; i<res.length; i++) {
        console.log("testing " + res[i]);
      }
      this.loadingService.loading.next(false);
    });
    this.apiService.activateRiders().subscribe((res: any) => {
      // console.log("activated riders : " + res);
      this.loadingService.loading.next(false);
    })
    window.alert("Order completed!");
    this.hasOrdered = !this.hasOrdered; 

  }

  showYourModal(i) {
    this.recentLocations = [];
    const rid = i+1;
    this.rid = rid; 
    const min = this.restaurants[i][2];
    var initialState = {
      list: [
        rid
      ],
      orderList: [
      ],
      minOrder: [
        min
      ],
      title:'List of food items'
    };
    
    this.bsModalRef = this.modalService.show( ModalContentComponent, {initialState});
    this.bsModalRef.content.closeBtnName = 'Close';
    this.apiService.getMostRecentLocation(this.uid).subscribe((location : any) => {
      // console.log("getting recent locations: " + location);
      for (let i = 0; i < location.length; i++) {
        this.recentLocations.push(location[i]["most_recent_location"]);
        // console.log("recent locations: " + location[i]["most_recent_location"]);
      }
      // console.log(this.recentLocations);
      this.loadingService.loading.next(false);
    })

    this.apiService.getRewardBalance(this.uid).subscribe((reward : any) => {
        console.log(reward);
        
        this.rewardsBal = reward[0]["reward_balance"];
        // console.log("rewards balance is : " + this.rewardsBal);
    })
    
  }

  confirmOrder() {

  }

  checkRewards() {

  }

  manualEntry() {
    this.locationDropdown = false;
  }

}


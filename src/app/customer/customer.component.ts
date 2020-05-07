import { Component, OnInit, ViewChild } from "@angular/core";
import { ActivatedRoute, Params } from "@angular/router";
import { LoadingService } from "../loading.service";
import { BsModalService, BsModalRef } from "ngx-bootstrap/modal";
import { ModalContentComponent } from "../modal-content/modal-content.component";
import { FormGroup, FormArray, FormControl, Validators } from "@angular/forms";
import { ApiService } from "../api.service";
import { DataService } from "../data.service";
import { Router } from "@angular/router";
import { TabsetComponent } from "ngx-bootstrap/tabs";
import { ToastrService } from "ngx-toastr";

@Component({
  selector: "app-customer",
  templateUrl: "./customer.component.html",
  styleUrls: ["./customer.component.css"],
})
export class CustomerComponent implements OnInit {
  @ViewChild("staticTabs", { static: false }) staticTabs: TabsetComponent;

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
  confirmedList = [];
  total;

  locationDropdown;
  recentLocations = [];
  rewardsBal;

  promoApplied: boolean;
  deliveryCost;
  creditCard: boolean; //boolean : if credit card --> true if cash --> false
  location; //string
  orderedPairs = [];

  retrievedDID: boolean; //check if did is retrieved

  deliveryid;
  orderid;

  riderName;
  riderRating;
  riderdeparturetime;
  orderTime;
  ridercollectedtime;
  deliverystarttime;

  onGoing: boolean;
  deliveryendtime;
  createReviewForm: FormGroup;
  foodreview;
  deliveryrating;

  constructor(
    private router: ActivatedRoute,
    private loadingService: LoadingService,
    private modalService: BsModalService,
    private apiService: ApiService,
    private dataService: DataService,
    public toastr: ToastrService
  ) {}

  ngOnInit() {
    this.deliveryCost = 5;
    this.deliveryid = -1;
    this.locationDropdown = true;
    this.promoApplied = false;
    this.retrievedDID = false;
    this.loadingService.loading.next(true);
    this.dataService.currentMessage.subscribe(
      (hasOrdered) => (this.hasOrdered = hasOrdered)
    );
    this.dataService.currentList.subscribe(
      (confirmedList) => (this.confirmedList = confirmedList)
    );
    this.dataService.currentFoodItems.subscribe(
      (foodItems) => (this.foodItems = foodItems)
    );
    this.dataService.currentTotal.subscribe((total) => (this.total = total));
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any) => {
          console.log(test[0].uid);
          console.log(test);
          this.uid = test[0].uid;

          this.apiService
            .getPastDeliveryRating(this.uid)
            .subscribe((delivery: any) => {
              for (let i = 0; i < delivery.length; i++) {
                let current = delivery[i]["past_delivery_ratings"];
                let result = current.substring(1, current.length - 1);
                let arr = result.split(",");
                this.pastDeliveries.push(arr);
                // console.log("past deliveries : " + arr);
              }
              this.loadingService.loading.next(false);
              // console.log("past deliveries : " + this.pastDeliveries[1][2]);
            });

          this.apiService
            .getPastFoodReviews(this.uid)
            .subscribe((review: any) => {
              for (let i = 0; i < review.length; i++) {
                let current = review[i]["past_food_reviews"];
                let result = current.substring(1, current.length - 1);
                let arr = result.split(",");
                this.pastReviews.push(arr);
              }
              this.loadingService.loading.next(false);
            });

          this.apiService.getRestaurants().subscribe((restaurant: any) => {
            for (let i = 0; i < restaurant.length; i++) {
              let current = restaurant[i]["list_of_restaurant"];
              let result = current.substring(1, current.length - 1);
              let arr = result.split(",");
              this.restaurants.push(arr);
            }
            this.loadingService.loading.next(false);
          });

          this.apiService.checkOngoing(this.uid).subscribe((boolean: any) => {
            console.log("is going + " + boolean);
            let answer = boolean[0]["bit"];

            if (answer == "1") {
              this.onGoing = true;
              console.log("ongoing varable is : " + this.onGoing);

              this.apiService.getDIDfromUID(this.uid).subscribe((did: any) => {
                console.log("did is: " + did[0]["case"]);
                this.deliveryid = did[0]["case"];
              });
            } else {
              this.onGoing = false;
              console.log("ongoing vairable is : " + this.onGoing);
            }
            this.loadingService.loading.next(false);
          });
        });
    });

    this.createOrderForm = new FormGroup({
      creditCard: new FormControl(""),
      location: new FormControl(""),
    });

    this.createReviewForm = new FormGroup({
      foodreview: new FormControl(""),
      deliveryrating: new FormControl(""),
    });
  }

  getDID() {
    // console.log("received did is :" + this.deliveryid);
    if (this.deliveryid != -1) {
      this.apiService.getRiderName(this.deliveryid).subscribe((name: any) => {
        console.log("riders name : " + name);
        this.riderName = name[0]["rider_name"];
      });
      this.apiService
        .getDeliveryTimings(this.deliveryid)
        .subscribe((timings: any) => {
          console.log("delivery timings : " + timings);
          this.orderTime = timings[0]["ordertime"];
          this.riderdeparturetime = timings[0]["riderdeparturetime"];
          this.ridercollectedtime = timings[0]["ridercollectedtime"];
          this.deliverystarttime = timings[0]["deliverystarttime"];
        });
      this.apiService
        .getRiderRating(this.deliveryid)
        .subscribe((rating: any) => {
          console.log("rider rating : " + rating);
          this.riderRating = rating[0]["rider_rating"];
        });

      this.retrievedDID = true;
    } else {
      this.toastr.show(
        "No ongoing deliveries at this moment. Please make an order! "
      );
    }
  }

  refresh() {
    this.apiService
      .getDeliveryTimings(this.deliveryid)
      .subscribe((timings: any) => {
        console.log("delivery timings : " + timings);
        this.orderTime = timings[0]["ordertime"];
        this.riderdeparturetime = timings[0]["riderdeparturetime"];
        this.ridercollectedtime = timings[0]["ridercollectedtime"];
        this.deliverystarttime = timings[0]["deliverystarttime"];
      });
    this.apiService
      .checkIfCompleted(this.deliveryid)
      .subscribe((completed: any) => {
        console.log("if completed: " + completed);
        console.log(completed[0]["ongoing"]);
        if ((completed[0]["ongoing"] = "false")) {
          this.onGoing = false;
          console.log("delivery is completed");
          this.apiService
            .getEndTime(this.deliveryid)
            .subscribe((endtime: any) => {
              this.deliveryendtime = endtime[0]["delivery_endtime"];
            });
        } else {
          this.toastr.show("Rider is still on the way! Please refresh later. ");
        }
      });
    this.toastr.show("Rider is still on the way! Please refresh later. ");
  }

  submitForm() {
    if (!this.onGoing) {
      console.log("confirmed list is: " + this.confirmedList);
      console.log("foodlist is: " + this.foodItems);
      var current = [];
      for (let i = 0; i < this.foodItems.length; i++) {
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
        delivery_fee: this.deliveryCost,
      };
      console.log("order askja" + order);

      // this.apiService.activateRiders().subscribe((res: any) => {
      //   // console.log("activated riders : " + res);
      //   this.loadingService.loading.next(false);
      // })

      this.apiService.updateOrderCount(order).subscribe((res: any) => {
        console.log("after posting" + res);
        for (let i = 0; i < res.length; i++) {
          console.log("testing " + res[i]);
        }
        this.loadingService.loading.next(false);
      });
      window.alert("Order completed! 🥳 ");
      this.hasOrdered = !this.hasOrdered;
      this.disableEnable();
      this.selectTab(1);
      this.apiService
        .getFoodandDeliveryID(this.uid, this.rid, this.total)
        .subscribe((res: any) => {
          console.log(
            "uid : " +
              this.uid +
              " rid is :" +
              this.rid +
              " total cost is :" +
              this.total
          );
          console.log(res);
          this.deliveryid = res[0]["deliveryid"];
          this.orderid = res[0]["orderid"];
          this.loadingService.loading.next(false);
          this.onGoing = true;
        });
    } else {
      window.alert(
        "You cannot order with an on going order 😡 ! Please wait for the current order to be done"
      );
    }
  }

  submitReview() {
    this.foodreview = this.createReviewForm.value.foodreview;
    this.deliveryrating = this.createReviewForm.value.deliveryrating;

    let review = {
      foodreview: this.foodreview,
      deliveryid: this.deliveryid,
    };
    this.apiService.foodReviewUpdate(review).subscribe((res: any) => {
      console.log(res);
      this.loadingService.loading.next(false);
    });

    let deliveryrating = {
      deliveryid: this.deliveryid,
      deliveryrating: this.deliveryrating,
    };
    this.apiService
      .updateDeliveryRating(deliveryrating)
      .subscribe((res: any) => {
        console.log("delivery rating submitted" + res);
        this.loadingService.loading.next(false);
      });
    this.disableEnable();
    this.selectTab(0);
    this.retrievedDID = false;
    this.deliveryid = -1;
    this.onGoing = false;
    window.alert(
      "Thank you for ordering with FoodHub! 🤤👍🏼💯🔥 Enjoy your food "
    );
  }

  showYourModal(i) {
    this.recentLocations = [];
    const rid = i + 1;
    this.rid = rid;
    const min = this.restaurants[i][2];
    var initialState = {
      list: [rid],
      orderList: [],
      minOrder: [min],
      title: "List of food items",
    };

    this.bsModalRef = this.modalService.show(ModalContentComponent, {
      initialState,
    });
    this.bsModalRef.content.closeBtnName = "Close";
    this.apiService
      .getMostRecentLocation(this.uid)
      .subscribe((location: any) => {
        // console.log("getting recent locations: " + location);
        for (let i = 0; i < location.length; i++) {
          this.recentLocations.push(location[i]["most_recent_location"]);
          // console.log("recent locations: " + location[i]["most_recent_location"]);
        }
        // console.log(this.recentLocations);
        this.loadingService.loading.next(false);
      });

    this.apiService.getRewardBalance(this.uid).subscribe((reward: any) => {
      console.log(reward);
      this.rewardsBal = reward[0]["reward_balance"];
      // console.log("rewards balance is : " + this.rewardsBal);
    });
  }

  applyPromo() {

    this.promoApplied = true; 
    if (!this.onGoing) {
      if (this.rewardsBal != 0) {
        let promo = {
          uid: this.uid,
          delivery_cost: 5
        };

        this.apiService.applyDeliveryPromo(promo).subscribe((res: any) => {
          console.log("after applying" + res);
          for (let i=0; i<res.length; i++) {
            console.log("testing " + res[i]);
          }
          this.loadingService.loading.next(false);
        });

        if (this.rewardsBal <= 5) {
          this.deliveryCost = this.deliveryCost - this.rewardsBal;
          this.rewardsBal = 0; 
        } else {
          this.deliveryCost = this.deliveryCost - 5; 
          this.rewardsBal = this.rewardsBal - 5; 
        }
        
      } else {
        window.alert("you do not have any reward points!");
      }
  } else {
    window.alert("You have an on going order!");
  }

  }

  manualEntry() {
    this.locationDropdown = false;
  }

  selectTab(tabId: number) {
    this.staticTabs.tabs[tabId].active = true;
  }
  disableEnable() {
    this.staticTabs.tabs[0].disabled = !this.staticTabs.tabs[0].disabled;
  }
}

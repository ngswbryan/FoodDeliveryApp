import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Data, Params, Router } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";
import { FormGroup, FormControl } from "@angular/forms";
import { ThrowStmt } from "@angular/compiler";

@Component({
  selector: "app-manager",
  templateUrl: "./manager.component.html",
  styleUrls: ["./manager.component.css"],
})
export class ManagerComponent implements OnInit {
  username;
  showLocation = false;
  showRiders = false;
  showCustomers = false;
  isCollapsed = true;
  isCollapsedOrders = true;
  selectedMonth = "5";
  selectedYear = "2020";
  newCustomers = [];
  totalOrders = [];
  totalCost = [];
  riderRole = true;
  location = [];
  customers = [];
  riders = [];
  availableLocations = [];
  currLocation = "all";
  campaigns = [];

  restaurants = [];

  newCampaign;

  createCampaign = new FormGroup({
    description: new FormControl(""),
    start: new FormControl(""),
    end: new FormControl(""),
    discount: new FormControl(""),
  });

  createRestaurant = new FormGroup({
    rname: new FormControl(""),
    location: new FormControl(""),
    minimum: new FormControl(""),
  });

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService
  ) {}

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.route.params.subscribe((params: Params) => {
      this.handlePeriodChange();
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any) => {
          this.apiService.getFDSCampaigns().subscribe((campaigns: any) => {
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
              this.campaigns.push(newPromo);
            }
            this.apiService.getRestaurants().subscribe((rest: any) => {
              for (let i = 0; i < rest.length; i++) {
                let current = rest[i]["list_of_restaurant"];
                let result = current.substring(1, current.length - 1);
                let arr = result.split(",");
                this.restaurants.push(arr);
              }
              console.log(this.restaurants);
              this.loadingService.loading.next(false);
            });
          });
        });
    });
  }

  deleteRestaurant(i) {
    this.loadingService.loading.next(true);
    this.apiService.deleteRestaurant(i).subscribe(() => {
      this.restaurants = [];
      this.apiService.getRestaurants().subscribe((rest: any) => {
        for (let i = 0; i < rest.length; i++) {
          let current = rest[i]["list_of_restaurant"];
          let result = current.substring(1, current.length - 1);
          let arr = result.split(",");
          this.restaurants.push(arr);
        }
        console.log(this.restaurants);
        this.loadingService.loading.next(false);
      });
    });
  }

  addRestaurant() {
    this.loadingService.loading.next(true);
    this.apiService.addRestaurant(this.createRestaurant.value).subscribe(() => {
      this.restaurants = [];
      this.apiService.getRestaurants().subscribe((rest: any) => {
        for (let i = 0; i < rest.length; i++) {
          let current = rest[i]["list_of_restaurant"];
          let result = current.substring(1, current.length - 1);
          let arr = result.split(",");
          this.restaurants.push(arr);
        }
        console.log(this.restaurants);
        this.loadingService.loading.next(false);
      });
    });
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

  deleteCampaign(id) {
    this.loadingService.loading.next(true);
    this.apiService.deleteFDSCampaign(id).subscribe(() => {
      this.campaigns = [];
      this.apiService.getFDSCampaigns().subscribe((campaigns: any) => {
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
          this.campaigns.push(newPromo);
        }
        this.loadingService.loading.next(false);
      });
    });
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

  addCampaign() {
    this.loadingService.loading.next(true);
    this.apiService.addFDSCampaign(this.createCampaign.value).subscribe(() => {
      this.campaigns = [];
      this.apiService.getFDSCampaigns().subscribe((campaigns: any) => {
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
          this.campaigns.push(newPromo);
        }
        this.loadingService.loading.next(false);
      });
    });
  }

  changeLocation() {
    this.location = [];
    this.loadingService.loading.next(true);
    this.showLocation = true;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .getLocation(this.selectedMonth, this.selectedYear, this.currLocation)
      .subscribe((location: any) => {
        this.location = location;
        this.loadingService.loading.next(false);
      });
  }

  seeLocation() {
    this.currLocation = "all";
    this.location = [];
    this.availableLocations = [];
    this.loadingService.loading.next(true);
    this.showLocation = true;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .getLocation(this.selectedMonth, this.selectedYear, "all")
      .subscribe((location: any) => {
        this.location = location;
        this.availableLocations = location;
        this.loadingService.loading.next(false);
      });
  }

  seeRiders() {
    this.riders = [];
    this.loadingService.loading.next(true);
    this.showLocation = false;
    this.showCustomers = false;
    this.showRiders = true;
    this.apiService
      .getRiders(this.selectedMonth, this.selectedYear)
      .subscribe((riders: any) => {
        console.log(riders);
        this.riders = riders;
        this.loadingService.loading.next(false);
      });
  }

  seeCustomers() {
    this.customers = [];
    this.loadingService.loading.next(true);
    this.showLocation = false;
    this.showCustomers = true;
    this.showRiders = false;
    this.apiService
      .getCustomers(this.selectedMonth, this.selectedYear)
      .subscribe((customer: any) => {
        for (let i = 0; i < customer.length; i++) {
          let tempString = customer[i].filterbymonth;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.customers.push(arr);
        }
        console.log(this.customers);
        this.loadingService.loading.next(false);
      });
  }

  handlePeriodChange() {
    this.newCustomers = [];
    this.totalCost = [];
    this.totalOrders = [];
    this.loadingService.loading.next(true);
    this.seeCustomers();
    this.seeLocation();
    this.seeRiders();
    this.showLocation = false;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .fetchMangerStatsByMonthAndYear(this.selectedMonth, this.selectedYear)
      .subscribe((stats: any) => {
        for (let i = 0; i < stats.length; i++) {
          let tempString = stats[i].new_customers;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.newCustomers.push(arr);
        }
        this.apiService
          .fetchMangerStatsByMonthAndYearOrders(
            this.selectedMonth,
            this.selectedYear
          )
          .subscribe((orders: any) => {
            for (let i = 0; i < orders.length; i++) {
              let tempString = orders[i].total_orders;
              let result = tempString.substring(1, tempString.length - 1);
              let arr = result.split(",");
              this.totalOrders.push(arr);
            }
            console.log(this.totalOrders);
            this.apiService
              .fetchMangerStatsByMonthAndYearCost(
                this.selectedMonth,
                this.selectedYear
              )
              .subscribe((cost: any) => {
                this.totalCost = cost;
                console.log(this.totalCost);
                this.loadingService.loading.next(false);
              });
          });
      });
  }
}

import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { switchMap } from "rxjs/internal/operators";
import { environment } from "../environments/environment";

@Injectable()
export class ApiService {
  constructor(private http: HttpClient) {}

  url = "http://localhost:3002";

  getUsers() {
    return this.http.get(`${this.url}/users`);
  }

  addUser(user) {
    return this.http.post(`${this.url}/users`, user);
  }

  getUserByUsername(username) {
    return this.http.get(`${this.url}/users/${username}`);
  }

  getStaffByUsername(uid) {
    return this.http.get(`${this.url}/staff/${uid}`);
  }

  getPastDeliveryRating(uid) {
    return this.http.get(`${this.url}/users/rating/${uid}`);
  }

  getPastFoodReviews(uid) {
    return this.http.get(`${this.url}/users/reviews/${uid}`);
  }

  getListOfFoodItem(rid) {
    return this.http.get(`${this.url}/users/restaurant/${rid}`);
  }

  getRestaurants() {
    return this.http.get(`${this.url}/restaurants`);
  }

  fetchMangerStatsByMonthAndYear(month, year) {
    return this.http.get(`${this.url}/manager?month=${month}&year=${year}`);
  }

  fetchMangerStatsByMonthAndYearOrders(month, year) {
    return this.http.get(
      `${this.url}/manager/orders?month=${month}&year=${year}`
    );
  }

  fetchMangerStatsByMonthAndYearCost(month, year) {
    return this.http.get(
      `${this.url}/manager/cost?month=${month}&year=${year}`
    );
  }

  getLocation(month, year, location) {
    return this.http.get(
      `${this.url}/manager/location?month=${month}&year=${year}&location=${location}`
    );
  }

  getRiders(month, year, role) {
    return this.http.get(
      `${this.url}/manager/riders?month=${month}&year=${year}&role=${role}`
    );
  }

  getCustomers(month, year) {
    return this.http.get(
      `${this.url}/manager/customers?month=${month}&year=${year}`
    );
  }

  deleteMenuItem(fname, rid) {
    return this.http.patch(
      `${this.url}/staff/menu?fname=${fname}&rid=${rid}`,
      {}
    );
  }

  addMenuItem(food) {
    return this.http.post(`${this.url}/staff/menu`, food);
  }

  getFoodItems() {
    return this.http.get(`${this.url}/test`);
  }
}

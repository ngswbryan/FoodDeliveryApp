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

  getLocation() {
    return this.http.get(`${this.url}/manager/location`);
  }

  getRiders() {
    return this.http.get(`${this.url}/manager/riders`);
  }

  getCustomers() {
    return this.http.get(`${this.url}/manager/customers`);
  }
}


import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { switchMap } from "rxjs/internal/operators";
import { environment } from "../environments/environment";

@Injectable()
export class ApiService {
  constructor(private http: HttpClient) {}

  getUsers() {
    return this.http.get("http://localhost:3002/users");
  }

  addUser(user) {
    return this.http.post("http://localhost:3002/users", user);
  }

  getUserByUsername(username) {
    return this.http.get(`http://localhost:3002/users/${username}`);
  }

  getRestaurants() {
    return this.http.get("http://localhost:3002/restaurants");
  }
}

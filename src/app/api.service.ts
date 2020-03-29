import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import {switchMap} from 'rxjs/internal/operators';
import { environment } from '../environments/environment';

@Injectable()
export class ApiService {
  url;

  constructor(private http: HttpClient) {
  }

  getBooks() {
    console.log(this.url);
    return this.http.get('/books');
  }

  getUsers() {
    return this.http.get('/users');
  }

}

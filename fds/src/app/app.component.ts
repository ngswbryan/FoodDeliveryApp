import { Component } from '@angular/core';
import { ApiService } from './api.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'fds';
  books = [ {
    title : "lol"
  }];

  constructor(private ApiService : ApiService) {

  }

  logBooks() {
    this.ApiService.getBooks().subscribe((books: any) => {
        this.books = books;
    });
  }
}

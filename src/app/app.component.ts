import { Component } from "@angular/core";
import { ApiService } from "./api.service";
import { LoadingService } from "./loading.service";

@Component({
  selector: "app-root",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.css"],
})
export class AppComponent {
  title = "fds";
  books = [
    {
      title: "lol",
    },
  ];

  public loading = false;

  constructor(
    private ApiService: ApiService,
    private loadingService: LoadingService
  ) {
    this.loadingService.loading.subscribe((load: any) => {
      this.loading = load;
    });
  }
}

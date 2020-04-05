import { BrowserModule } from "@angular/platform-browser";
import { NgModule } from "@angular/core";
import { HttpClientModule } from "@angular/common/http";
import { ModalModule } from "ngx-bootstrap/modal";
import { TooltipModule } from "ngx-bootstrap/tooltip";
import { NgxLoadingModule } from "ngx-loading";
import { AppRoutingModule } from "./app-routing.module";
import { AppComponent } from "./app.component";
import { ApiService } from "./api.service";
import { LoginComponent } from "./login/login.component";
import { LoadingComponent } from "./loading/loading.component";
import { LoadingService } from "./loading.service";
import { RiderComponent } from "./rider/rider.component";
import { CustomerComponent } from "./customer/customer.component";
import { StaffComponent } from "./staff/staff.component";
import { ManagerComponent } from "./manager/manager.component";
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";
import { ToastrModule } from "ngx-toastr";
import { RegisterComponent } from "./register/register.component";
import { FormsModule, ReactiveFormsModule } from "@angular/forms";

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    LoadingComponent,
    RiderComponent,
    CustomerComponent,
    StaffComponent,
    ManagerComponent,
    RegisterComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    ModalModule.forRoot(),
    TooltipModule.forRoot(),
    NgxLoadingModule.forRoot({}),
    BrowserAnimationsModule,
    ToastrModule.forRoot(),
    FormsModule,
    ReactiveFormsModule
  ],
  providers: [ApiService, LoadingService],
  bootstrap: [AppComponent]
})
export class AppModule {}

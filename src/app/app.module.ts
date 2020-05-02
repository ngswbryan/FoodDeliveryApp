import { BrowserModule } from "@angular/platform-browser";
import { NgModule } from "@angular/core";
import { HttpClientModule } from "@angular/common/http";
import { ModalModule, BsModalRef } from "ngx-bootstrap/modal";
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
import { TabsModule } from "ngx-bootstrap/tabs";
import { AccordionModule } from "ngx-bootstrap/accordion";
import { AlertModule } from "ngx-bootstrap/alert";
import { ModalContentComponent } from './modal-content/modal-content.component';
import { CollapseModule } from "ngx-bootstrap/collapse";
import { ProgressbarModule } from "ngx-bootstrap/progressbar";

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    LoadingComponent,
    RiderComponent,
    CustomerComponent,
    StaffComponent,
    ManagerComponent,
    RegisterComponent,
    ModalContentComponent
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
    ReactiveFormsModule,
    TabsModule.forRoot(),
    AccordionModule.forRoot(),
    AlertModule.forRoot(),
    CollapseModule.forRoot(),
    ProgressbarModule.forRoot(),
  ],
  providers: [ApiService, LoadingService, BsModalRef],
  bootstrap: [AppComponent],
  entryComponents: [ModalContentComponent]
})
export class AppModule {}

import { Navigate, Route, Routes } from "react-router-dom";
import Layout from "./components/Layout";
import Onboarding from "./pages/Onboarding";
import Assessment from "./pages/Assessment";
import Result from "./pages/Result";
import AdminLogin from "./pages/admin/Login";
import AdminDashboard from "./pages/admin/Dashboard";

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Onboarding />} />
        <Route path="/assessment/:assessmentId" element={<Assessment />} />
        <Route path="/result/:resultId" element={<Result />} />
        <Route path="/admin" element={<Navigate to="/admin/login" replace />} />
        <Route path="/admin/login" element={<AdminLogin />} />
        <Route path="/admin/dashboard" element={<AdminDashboard />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  );
}
